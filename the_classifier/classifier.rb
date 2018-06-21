
require 'rubygems'
require 'geokit'
require 'SVM'

include SVM

class Linha_CSV <
	# Cada linha do arquivo CSV contem
	# (endereco; idade; quer ter filhos?; fuma?)
	# do homem e da mulher, lista de interesses comuns
	# e se combinam. (0: Nao combinam; 1: Combinam)
	Struct.new(:combinam, :row)
end

# Le arquivo 'csv' e retorna as linhas lidas.
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

		# Cria uma nova linha 'csv'.
		l = Linha_CSV.new

		# Organiza os dados lidos.
		distancia = distancia_KM(dados[4].to_s, dados[9].to_s)
		filho_H = representacao_numerica(dados[2].to_s)
		filho_M = representacao_numerica(dados[7].to_s)
		fuma_H = representacao_numerica(dados[1].to_s)
		fuma_M = representacao_numerica(dados[6].to_s)
		idade_H = dados[0].to_f
		idade_M = dados[5].to_f
		interesses = interesses_comuns(dados[3].to_s, dados[8].to_s)
		l.combinam = dados[10].to_i
		l.row = [idade_H, fuma_H, filho_H, idade_M, fuma_M, filho_M, interesses, distancia]
		linhas.push(l)
	}

	# Fechar arquivo apos usa-lo.
	arquivo.close

	# Retorna as linhas lidas do arquivo.
	return linhas
end

# Verifica a distancia entre duas posicoes (latitude e longitude) em KMs.
def distancia_KM (posA = 'Campinas, SP', posB = 'Campinas, SP')
	a = Geokit::Geocoders::GoogleGeocoder.geocode(posA)
	b = Geokit::Geocoders::GoogleGeocoder.geocode(posB)
	return a.distance_to(b, {:units => :kms})
end

# Divide as linhas 'csv' em linhas para testar e treinar.
def div_rows(rows = [], num_testar = 10, num_treinar = 10)
	# Cria um novo array de linhas.
	rows_testar = Array.new
	rows_treinar = Array.new

	i = 0 # Indice do vetor.

	num_testar.times {
		rows_testar.push(rows[i])
		i += 1 # Incrementa o indice.
	}

	num_treinar.times {
		rows_treinar.push(rows[i])
		i += 1 # Incrementa o indice.
	}

	# Retorna os vetores que serao usado para testar e treinar.
	return [rows_testar, rows_treinar]
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

# Normaliza as linhas lidas do arquivo 'csv'.
def normalizar_linhas (rows_csv)
	# Cria um novo array de linhas 'csv'.
	linhas_csv = Array.new

	# Obtem o normalizador.
	normalizador = normalizar(rows_csv)

	rows_csv.each { |r|
		# Cria uma nova linha 'csv'.
		l = Linha_CSV.new
		l.combinam = r.combinam
		l.row = normalizador.call(r.row)
		linhas_csv.push(l)
	}

	return linhas_csv
end

# Obtem a porcentagem de uma certa amostra.
def porcentagem (amostragem, total)
	p = (amostragem * 100)/total

	# Retorna uma string contendo a porcentagem.
	return p.to_s + "%"
end

# Representacao de Naos e Sims em forma numerica.
def representacao_numerica (valor = 'no')
	return (-1) if valor == 'no'
	return 1 if valor == 'yes'
	return 0
end

# Testa e verifica dados novos gerando um arquivo resultante.
def testar (arquivo_csv = 'matchmaker.csv', arquivo_out = 'saida.txt')
	# Le arquivo 'csv' e obtem os dados do arquivo.
	rows_csv = arquivo(arquivo_csv)
	puts "Arquivo '" + arquivo_csv + "' lido."

	# Normalizando os dados lidos.
	rows_csv = normalizar_linhas(rows_csv)
	puts "Os dados foram normalizados."

	# Divide as linhas lidas do arquivo 'csv' para testar e treinar.
	rows_testar, rows_treinar = div_rows(rows_csv, 100, 400)

	# Definindo parametros para Kernel.
	param = Parameter.new
	param.degree = 3			# poly
	param.gamma = 0.125			# poly/rbf/sigmoid
	param.coef0 = 0				# poly/sigmoid
	param.cache_size = 40.0		# em MB
	param.eps = 0.01			# stopping criteria
	param.C = 1.0				# C_SVC, EPSILON_SVR, and NU_SVR
	param.nu = 0.5				# NU_SVC, ONE_CLASS, and NU_SVR
	param.p = 0.1				# EPSILON_SVR

	prob = Problem.new

	rows_treinar.each { |r|
		prob.addExample(r.combinam, r.row)
	}

	# Tipos de Kernels.
	kerneln = ['Linear', 'Polynomial', 'Radial basis function', 'Sigmoid']
	kernels = [LINEAR, POLY, RBF, SIGMOID]

	# Abrir arquivo 'out' para escrita.
	arquivo = File.open(arquivo_out, 'w')

	kernels.each_index { |k|
		ac = 0 # Contador de acertos.
		er = 0 # Contador de erros.

		param.kernel_type = kernels[k]
		m = Model.new(prob, param)

		rows_testar.each { |r|
			if r.combinam == m.predict(r.row)
				ac += 1
			else
				er += 1
			end
		}

		# Impressao de resultados.
		arquivo.puts "- - - - - - - - - - - - - - - - -"
		arquivo.puts "Kernel type: " + kerneln[k]
		arquivo.puts "- - - - - - - - - - - - - - - - -"
		arquivo.puts "degree: " + param.degree.to_s
		arquivo.puts "gamma: " + param.gamma.to_s
		arquivo.puts "coef0: " + param.coef0.to_s
		arquivo.puts "cache_size: " + param.cache_size.to_s
		arquivo.puts "eps: " + param.eps.to_s
		arquivo.puts "C: " + param.C.to_s
		arquivo.puts "nu: " + param.nu.to_s
		arquivo.puts "p: " + param.p.to_s
		arquivo.puts "- - - - - - - - - - - - - - - - -"
		arquivo.puts "Num. dados: " + rows_csv.length.to_s
		arquivo.puts "Amostragem (TESTE): " + rows_testar.length.to_s + ", amostragem (TREINO): " + rows_treinar.length.to_s
		arquivo.puts "Num. acertos: " + ac.to_s + " (" + porcentagem(ac, rows_testar.length) + "), num. erros: " + er.to_s + " (" + porcentagem(er, rows_testar.length) + ")"
		arquivo.puts "- - - - - - - - - - - - - - - - -"
	}

	# Fechar arquivo apos usa-lo.
	arquivo.close
end

# Executa o teste do classificador.
testar("matchmaker.csv", "saida.txt")
