# Bundle Identifier
- br.gov.sp.educacao.SEDProfessor
- com.tests.prodesp.diario

# Color
- #368EEC

# Login Homologação
- user: rg90591975sp

# Repositorio
- https://seducsp.visualstudio.com/DefaultCollection/SEDiOS/_git/DiarioDeClasseiOS

# Api
- Homologação: https://homologacaosed.educacao.sp.gov.br/SedApi/Api/
- Produção: https://sed.educacao.sp.gov.br/SedApi/Api/

# Enviar para produção
- Na classe Constants, trocar BackendApiServerUrl de developmentUrl para productionUrl;
- Na classe Constants, trocar ProductionEnable e ServerEnable de false para true;
- Na classe Constants, AutoCompleteLogin trocar de true para false;
- Clicar em Edit Scheme e ativar o Background Fetch em Run;
- Rodar o Unit Tests. Se preferir pode utilizar o fastlane rodando o comando no terminal, dentro do diretório do projeto: fastlane scan
