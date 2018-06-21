
Proposta
-----------------------------------------------------------------------------------------
Fazer um programa para treinar e fazer cross_validation com o arquivo
matchmaker.csv, usando a LIBSVM, conforme mostrado na última aula. O programa deve ler o
arquivo matchmaker.csv, transformar os dados em valores numéricos, normalizar/escalonar os
dados e treinar a LIBSVM.

Além do código do programa em Ruby, os alunos deverão fazer simulações com
diferentes parâmetros para o modelo da LIBSVM. Podem e devem variar o maior número de
parâmetros possíveis. Quanto mais rico em simulações, melhor. Como parâmetros entendam:
o kernel_type (LINEAR, POLY, RBF, SIGMOID).

for poly
-----------------------------------------------------------------------------------------
int degree

for poly/rbf/sigmoid
-----------------------------------------------------------------------------------------
double gamma

for poly/sigmoid
-----------------------------------------------------------------------------------------
double coef0

in MB
-----------------------------------------------------------------------------------------
double cache_size

stopping criteria
-----------------------------------------------------------------------------------------
double eps

for C_SVC, EPSILON_SVR, and NU_SVR
-----------------------------------------------------------------------------------------
double C

for NU_SVC, ONE_CLASS, and NU_SVR
-----------------------------------------------------------------------------------------
double nu

for EPSILON_SVR
-----------------------------------------------------------------------------------------
double p

Para “testar/verificar” se o resultado obteve melhoras (ou se piorou) para cada valor de
parâmetro setado, usem a cross_validation (com valor de n = 4). Depois verifiquem quantos
acertos e erros cada teste gerou. No relatório, devem ser tabulados todos os resultados, para
encontrar os melhores ajustes.
