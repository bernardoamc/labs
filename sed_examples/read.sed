/^<Empresas>/r company.list
/^<Empresas>/d

# O que vai acontecer nesse caso:
# 1 - Ao dar match em /^<Empresas>/ leremos o arquivo company.list
# 2 - O conteudo desse arquivo sera appendado apos /^<Empresas>/
# 3 - Deletaremos a linha contendo /^<Empresas>/
