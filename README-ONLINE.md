# CicloFit 5.0 — publicação online gratuita

## Estrutura recomendada
- GitHub: versionamento do código.
- Netlify Free: hospedagem do frontend estático.
- Supabase Free: PostgreSQL + Auth + Storage na segunda etapa.

## 1) Teste imediato (sem banco)
O projeto atual continua funcionando com localStorage. Basta publicar a pasta `CicloFit` no Netlify.

## 2) Supabase
1. Crie um projeto gratuito no Supabase.
2. Abra SQL Editor e execute `supabase/schema.sql`.
3. Copie `js/cloud-config.example.js` para `js/cloud-config.js`.
4. Preencha `supabaseUrl` e a Publishable Key.
5. Deixe `enabled: false` enquanto estiver apenas publicando.
6. Ative `enabled: true` somente durante a etapa de integração/teste da ponte.

## Segurança
Nunca use `service_role` no navegador. Ela é chave privilegiada de servidor.

## Netlify
O arquivo `netlify.toml` já define a pasta raiz como publicação e o fallback para `index.html`.

## Próxima etapa de desenvolvimento
Migrar o login para Supabase Auth e trocar as rotinas locais de alunos, treinos, histórico de pedais e perfis pelas tabelas SQL.
