
class Linha_CSV <
	# Cada linha do arquivo CSV contem a idade do homem,
	# da mulher e se combinam. (0: Nao combinam; 1: Combinam)
	Struct.new(:idade_homem, :idade_mulher, :combinam)
end

class Linha_IN <
	# Cada linha do arquivo IN contem a idade do homem e da mulher.
	Struct.new(:idade_homem, :idade_mulher)
end

# Le arquivo 'csv' e obtem os dados do arquivo para gerar pontos
# medios para as categorias 'Combinam' e 'Nao combinam'.
def csv (nome_arquivo = 'idades.csv')
	# Contadores necessarios para obter os pontos medios.
	contador_0 = 0 # Numero de elementos na categoria 'Combinam'.
	contador_1 = 0 # Numero de elementos na categoria 'Nao combinam'.

	# Cria um novo array de linhas lidas do arquivo.
	linhas_csv = Array.new

	# Valores somados necessarios para obter os pontos medios.
	soma_H0 = 0 # Soma das idades de Homens que combinam.
	soma_H1 = 0 # Soma das idades de Homens que nao combinam.
	soma_M0 = 0 # Soma das idades de Mulheres que combinam.
	soma_M1 = 0 # Soma das idades de Mulheres que nao combinam.

	# Abrir arquivo 'csv' para leitura.
	arquivo = File.open(nome_arquivo, 'r')

	# Para cada linha lida, adicionar dados ao array.
	arquivo.each_line { |line|
		# Divide os dados da linha lida.
		dados = line.split(',')

		# Cria uma nova linha 'csv'.
		l = Linha_CSV.new

		# Estrutura os dados lidos.
		l.idade_homem = dados[0].to_f
		l.idade_mulher = dados[1].to_f
		l.combinam = dados[2].to_i
		linhas_csv.push(l)
	}

	# Fechar arquivo apos usa-lo.
	arquivo.close

	# Soma as idades (p/ Homem e Mulher) e calcula o ponto medio de cada categoria.
	linhas_csv.each { |l|
		if l.combinam == 0
			contador_0 += 1
			soma_H0 += l.idade_homem
			soma_M0 += l.idade_mulher
		elsif l.combinam == 1
			contador_1 += 1
			soma_H1 += l.idade_homem
			soma_M1 += l.idade_mulher
		end
	}

	# Retorna os pontos medios [id. med. Homem (0), id. med. Mulher (0), id. med. Homem (1), id. med. Mulher (1)]
	return Array[Float(soma_H0/contador_0), Float(soma_M0/contador_0), Float(soma_H1/contador_1), Float(soma_M1/contador_1)]
end

# Classifica se um ponto 'Combina' ou 'Nao combina' baseados nos dados lidos do arquivo 'csv'.
# Ponto a ser classificado: X[ponto x, ponto y]
# avgs[id. med. Homem (0), id. med. Mulher (0), id. med. Homem (1), id. med. Mulher (1)]
def dp_classify (x = [], avgs = [])
	# M0 e o ponto medio da categoria 'Nao combinam'.
	# M1 e o ponto medio da categoria 'Combinam'.

	# vetorA = X - (M0 + M1)/2
	vetorA_x = x[0].to_f - ((avgs[0].to_f + avgs[2].to_f)/2)
	vetorA_y = x[1].to_f - ((avgs[1].to_f + avgs[3].to_f)/2)

	# vetorB = (M0 - M1)
	vetorB_x = avgs[0].to_f - avgs[2].to_f
	vetorB_y = avgs[1].to_f - avgs[3].to_f

	# produto_escalar(vetorA, vetorB) = vetorA[0] * vetorB[0] + vetorA[1] * vetorB[1]
	produto_escalar = (vetorA_x * vetorB_x) + (vetorA_y * vetorB_y)

	#Se produto_escalar(vetorA, vetorB) for maior que zero, o ponto 'x' e da categoria 0, senao, da categoria 1.
	return 0 if produto_escalar > 0
	return 1
end

def testar (arquivo_csv = 'idades.csv', arquivo_in = 'idades.in', arquivo_txt = 'saida.txt')
	puts "Arquivo '" + arquivo_csv + "' lido."

	# Le arquivo 'csv' e obtem os dados do arquivo para gerar pontos
	# medios para as categorias 'Combinam' e 'Nao combinam'.
	avgs = csv(arquivo_csv)

	# Cria um novo array de linhas lidas do arquivo.
	linhas_in = Array.new

	puts "Arquivo '" + arquivo_in + "' lido."

	# Abrir arquivo 'in' para leitura.
	arquivo = File.open(arquivo_in, 'r')

	# Para cada linha lida, adicionar dados ao array.
	arquivo.each_line { |line|
		# Divide os dados da linha lida.
		dados = line.split(',')

		# Cria uma nova linha 'in'.
		l = Linha_IN.new

		# Estrutura os dados lidos.
		l.idade_homem = dados[0].to_f
		l.idade_mulher = dados[1].to_f
		linhas_in.push(l)
	}

	# Fechar arquivo apos usa-lo.
	arquivo.close

	puts "Resultado do teste escrito no arquivo '" + arquivo_txt + "'."

	# Abrir arquivo 'in' para escrita.
	arquivo = File.open(arquivo_txt, 'w')

	linhas_in.each { |l|
		arquivo.puts(dp_classify([l.idade_homem, l.idade_mulher], avgs))
	}

	# Fechar arquivo apos usa-lo.
	arquivo.close
end

# Executa o teste do classificador.
testar("idades.csv","idades.in","saida.txt")
