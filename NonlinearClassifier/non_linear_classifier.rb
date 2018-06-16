
require 'rubygems'
require 'geokit'

class Linha_CSV <
	# Cada linha do arquivo CSV contem
	# (endereco; idade; quer ter filhos?; fuma?)
	# do homem e da mulher, lista de interesses comuns
	# e se combinam. (0: Nao combinam; 1: Combinam)
	Struct.new(:combinam, :row)
end

class Linha_IN <
	# Cada linha do arquivo IN contem
	# (endereco; idade; quer ter filhos?; fuma?)
	# do homem e da mulher, lista de interesses comuns.
	Struct.new(:row)
end

# Le arquivo 'csv' ou 'in' e retorna as linhas lidas.
def arquivo (nome_arquivo = 'matchmaker.csv')
	# Divide o nome e a extensao do arquivo.
	nome_do_arquivo = nome_arquivo.split('.')

	# Cria um novo array de linhas lidas do arquivo.
	linhas = Array.new

	# Abrir arquivo para leitura.
	arquivo = File.open(nome_arquivo, 'r')

	# Para cada linha lida, adicionar dados ao array.
	arquivo.each_line { |line|
		# Divide os dados da linha lida.
		dados = line.split(',')

		# Cria uma nova linha 'csv' ou 'in'.
		l = Linha_CSV.new if nome_do_arquivo[1].to_s == 'csv'
		l = Linha_IN.new  if nome_do_arquivo[1].to_s == 'in'

		# Organiza os dados lidos.
		distancia = distancia_KM(dados[4].to_s, dados[9].to_s)
		filho_H = representacao_numerica(dados[2].to_s)
		filho_M = representacao_numerica(dados[7].to_s)
		fuma_H = representacao_numerica(dados[1].to_s)
		fuma_M = representacao_numerica(dados[6].to_s)
		idade_H = dados[0].to_f
		idade_M = dados[5].to_f
		interesses = interesses_comuns(dados[3].to_s, dados[8].to_s)
		l.combinam = dados[10].to_i if nome_do_arquivo[1].to_s == 'csv'
		l.row = [idade_H, fuma_H, filho_H, idade_M, fuma_M, filho_M, interesses, distancia]
		linhas.push(l)
	}

	# Fechar arquivo apos usa-lo.
	arquivo.close

	# Retorna as linhas lidas do arquivo.
	return linhas
end

# Calcula a diferenca entre vetores.
def diff (v1 = [], v2 = [])
	# Os vetores devem ter o mesmo tamanho.
	return nil if v1.length != v2.length

	i = 0 # Indice do vetor.

	# Vetor resultante.
	vr = Array.new(v1.length)

	vr.each {
		vr[i] = v1[i] - v2[i]
		i += 1 # Incrementa o indice.
	}

	# Retorna a diferenca dos vetores.
	return vr
end

# Verifica a distancia entre duas posicoes (latitude e longitude) em KMs.
def distancia_KM (posA = 'Campinas, SP', posB = 'Campinas, SP')
	a = Geokit::Geocoders::GoogleGeocoder.geocode(posA)
	b = Geokit::Geocoders::GoogleGeocoder.geocode(posB)
	return a.distance_to(b, {:units => :kms})
end

# Verifica se valor existe no vetor.
def existe (valor, v = [])
	# Valor retornado.
	existe = false

	v.each { |x|
		if valor == x
			existe = true
			break
		end
	}

	# Valor existe?
	return existe
end

# Gera o vetor normalizado de dados.
def gerar_normalizado (row = [], max = [], min = [])
	# Os vetores devem ter o mesmo tamanho.
	return nil if max.length != min.length and max.length != row.length

	i = 0 # Indice do vetor.

	# Vetor normalizado.
	vn = Array.new(max.length)

	vn.each {
		vn[i] = (row[i] - min[i])/(max[i] - min[i])
		i += 1 # Incrementa o indice.
	}

	# Retorna o vetor normalizado.
	return vn
end

# Funcao de Calculo de Offset
def get_offset (rows, gamma = 10)
	categoria0 = Array.new
	categoria1 = Array.new
	rows.each { |r|
		if r.combinam == 0
			categoria0.push(r)
		else
			categoria1.push(r)
		end
	}
	soma0 = somatorio_dos_rbf_entre_todos_os_pontos(categoria0, gamma)
	soma1 = somatorio_dos_rbf_entre_todos_os_pontos(categoria1, gamma)
	return ((soma1/(categoria1.length**2)) - (soma0/(categoria0.length**2)))
end

# Contabiliza os interesses comuns.
def interesses_comuns (interesses_H, interesses_M)
	# Contador de interesses comuns.
	contador = 0

	# Divide os interesses do Homem e da Mulher.
	iH = interesses_H.split(':')
	iM = interesses_M.split(':')

	# Verifica a igualdade de itens nas duas listas.
	# Incrementa o contador a cada igualdade.
	iH.each { |h|
		iM.each { |m|
			contador += 1 if h == m
		}
	}

	# Retorna o contador de interesses comuns.
	return contador
end

# Funcao de Classificacao nao Linear via RBF e Offset.
def nl_classify (x = [], rows = [], offset = 0, gamma = 10)
	contador0 = 0
	contador1 = 0
	soma0 = 0
	soma1 = 0
	rows.each { |r|
		if r.combinam == 0
			soma0 += rbf(x, r.row, gamma)
			contador0 += 1
		else
			soma1 += rbf(x, r.row, gamma)
			contador1 += 1
		end
	}
	return 0 if ((soma0/contador0) - (soma1/contador1) + offset) > 0
	return 1
end

# Obtem o vetor normalizado.
def normalizar (rows = [])
	# Obtem os vetores maximo e minimo.
	if rows.length > 1 then
		i1 = 0 # Indice de colunas.
		i2 = 0 # Indice de linhas.

		# Vetores resultantes.
		max = Array.new(rows[0].row.length)
		min = Array.new(rows[0].row.length)

		rows.each { |r1|
			r1.row.each { |r2|
				max[i1] = r2 if i2 == 0 or r2 > max[i1]
				min[i1] = r2 if i2 == 0 or r2 < min[i1]
				i1 += 1
			}
			i1  = 0
			i2 += 1
		}

		return Proc.new { |row| gerar_normalizado(row, max, min) }
	end
end

# Normaliza as linhas lidas do arquivo 'csv' e 'in'.
def normalizar_linhas (rows_csv, rows_in)
	# Cria um novo array de linhas 'csv' e 'in'.
	linhas_csv = Array.new
	linhas_in = Array.new

	# Obtem o normalizador.
	normalizador = normalizar(rows_csv)

	rows_csv.each { |r1|
		# Cria uma nova linha 'csv'.
		l = Linha_CSV.new
		l.combinam = r1.combinam
		l.row = normalizador.call(r1.row)
		linhas_csv.push(l)
	}

	rows_in.each { |r2|
		# Cria uma nova linha 'in'.
		l = Linha_IN.new
		l.row = normalizador.call(r2.row)
		linhas_in.push(l)
	}

	return [linhas_csv, linhas_in]
end

# Funcao de Base Radial.
def rbf (v1 = [], v2 = [], gamma = 10)
	return nil if v1.length != v2.length
	dv = diff(v1, v2)
	l = veclength(dv)
	Math::exp(-gamma * l)
end

# Representacao de Naos e Sims em forma numerica.
def representacao_numerica (valor = 'no')
	return (-1) if valor == 'no'
	return 1 if valor == 'yes'
	return 0
end

# Calcula a soma de RBFs entre todos os pontos de uma categoria.
def somatorio_dos_rbf_entre_todos_os_pontos (rows = [], gamma = 10)
	somatorio = 0 # Valor da soma.

	rows.each { |row1|
		rows.each { |row2|
			somatorio += rbf(row1.row, row2.row, gamma)
		}
	}

	# Retorna a somatoria calculada.
	return somatorio
end

# Testa e verifica dados novos gerando um arquivo resultante.
def testar (arquivo_csv = 'matchmaker.csv', arquivo_in = 'data.in', arquivo_out = 'data.out')
	# Le arquivo 'csv' e obtem os dados do arquivo.
	rows_csv = arquivo(arquivo_csv)
	puts "Arquivo '" + arquivo_csv + "' lido."

	# Le arquivo 'in' e obtem os dados do arquivo.
	rows_in = arquivo(arquivo_in)
	puts "Arquivo '" + arquivo_in + "' lido."

	# Normalizando os dados lidos.
	rows_csv, rows_in = normalizar_linhas(rows_csv, rows_in)
	puts "Os dados foram normalizados."

	# Calcular o offset.
	offset = get_offset(rows_csv)
	puts "Offset calculado (" + offset.to_s + ")."
	puts "O resultado sera escrito no arquivo '" + arquivo_out + "'."

	# Abrir arquivo 'out' para escrita.
	arquivo = File.open(arquivo_out, 'w')

	rows_in.each { |r|
		arquivo.puts(nl_classify(r.row, rows_csv,offset))
	}

	# Fechar arquivo apos usa-lo.
	arquivo.close
end

# Calcula o valor de ||vetor||.
def veclength (v)
	soma = 0 # Somatorio de v[x]^2.

	v.each{ |x|
		soma += (x**2)
	}

	# Retorna o valor calculado de ||vetor||.
	return Math.sqrt(soma)
end

# Executa o teste do classificador.
testar("matchmaker.csv","data.in","data.out")
