## CLI de projeto/cliente/empresa

Para facilitar o uso de Vault, e possivelmente outras ferramentas que forem adicionadas ao longo do projeto se faz necessário implementar uma interface que facilite o consumo dessas ferramentas.

É impecindivel a equipe de DevOps e SRE entender que não é a principal função dos demais integrantes do time ficar aprendendo o ferramental adotado por esses profissionais. 

Mesmo tendo que considerar mitigar duvidas técnicas dos demais membros do projeto sobres ferramentas adotadas, não deve ser um impecilio para a adoção do *workflow* proposto, as diversas interfaces com ferramentas distintas. 

Portanto deve-se sempre considerar como será a experiência do desenvolvedor para minimizar o impacto da adoção das boas práticas propostas.

### Instalação 
```bash
sudo cp cli/citcli /usr/local/bin/
chmod +x /usr/local/bin/citcli
```

ou

```bash
make deploy_cli
```
