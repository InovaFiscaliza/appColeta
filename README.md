# appColeta  [![Ask DeepWiki](https://deepwiki.com/badge.svg)](https://deepwiki.com/InovaFiscaliza/appColeta)

O appColeta é uma ferramenta de controle de instrumentos – em especial analisadores de espectro e GPSs – e coleta de dados de monitorações do espectro de radiofrequências. 
- O app é compatível com receptores e analisadores de espectro fabricados pela Rohde & Schwarz (EB500, FSL, FSVR e FSW), KeySight (N9344C e N9936B), Tektronix (SA2500) e Anritsu (MS2027); GPSs; ACUs e comutador (EMSat). 
- O app possui diversos tipos de tarefas de monitoração, com destaque para a tarefa “Rompimento de máscara espectral”, que possibilita observar o comportamento de emissões intermitentes em faixas críticas, e "Drive-test (Level+Azimuth)", que possibilita estimar os locais de instalação de fontes de emissões evidenciadas na monitoração.
- Os arquivos gerados pelo app são pós-processados no appAnalise.

EXECUÇÃO DE TAREFAS DE MONITORAÇÃO
<img width="1920" height="1032" alt="Screenshot 2025-10-29 000016" src="https://github.com/user-attachments/assets/14e88598-e296-40a7-88f2-373466e31530" />

#### COMPATIBILIDADE  
A ferramenta foi desenvolvida em **MATLAB** e possui uma versão *desktop*, que pode ser utilizada em ambiente offline. O appColeta é compatível com as versões mais recentes do MATLAB (ex.: *R2024a* e *R2025a*). A versão compilada é executada sobre a máquina virtual do MATLAB, o MATLAB Runtime.  

#### EXECUÇÃO NO AMBIENTE DO MATLAB  
Caso o aplicativo seja executado diretamente no MATLAB, é necessário:
1. Clonar o presente repositório.
2. Clonar também o repositório [SupportPackages](https://github.com/InovaFiscaliza/SupportPackages), adicionando ao *path* do MATLAB a seguinte pasta deste repositório:  
```
.\src\General
```

3. Abrir o projeto **appColeta.prj**.
4. Executar **winAppColeta.mlapp**.

Outras informações em https://anatel365.sharepoint.com/sites/InovaFiscaliza/SitePages/appColeta.aspx
