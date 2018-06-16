
Proposta
-----------------------------------------------------------------------------------------
1) O programa deve implementar um Classificador Linear conforme visto em aula.

2) O classificador implementado deve ter uma funcao (um metodo em Ruby) de treinamento,
que le um arquivo CSV com idades dos homens e mulheres e um terceiro parametro dizendo se
combinam (1) ou se não combinam (0). Conforme arquivo "idades.csv" em anexo.

3) A saída deste método deve ser um array com os pontos médios das categorias (combina e
não combina) calculados para o conjunto de dados contidos no arquivo. (array "avgs")

4) O classificador deve ter também uma função para classificação de novos dados a partir
do treinamento feito no método anterior. A assinatura do método deve ser: dp_classify(X, avgs)

Esta classificação será feita via produto escalar de 2 vetores, são eles:

Vetor A: X - (M0 + M1)/2
Vetor B: M0 - M1

Onde X é o novo dado a ser classificado (um array com a idade do homem e a da mulher):
-----------------------------------------------------------------------------------------
M0 é o ponto médio da categoria não combinam
M1 é o ponto médio da categoria combinam

O produto escalar destes dois vetores é igual a:
-----------------------------------------------------------------------------------------
ProdEscalar(Vetor A, Vetor B) = ProdEscalar(X - (M0+M1)/2, M0 - M1) = ProdEscalar(X,M0) - ProdEscalar(X, M1) + (ProdEscalar(M1,M1) - ProdEscalar(M0,M0))/2

Se ProdEscalar(Vetor A, Vetor B) for maior que zero, o ponto X é da categoria 0, senão,
da categoria 1.

Onde ProdEscalar(V1,V2) = V1[0] * V2[0] + V1[1] * V2[1]

5) Faca um programa que leia um arquivo chamado idades.in, contendo N pares de idades de homens
e mulheres (1 par em cada linha, separados por virgulas), exemplo:

30,30
30,25
25,40
48,20

Gere um arquivo de saída chamado saida.txt, contendo as categorias para cada par, uma em cada
linha (0 no caso de não combinarem e 1 no caso de combinarem).
