# TradePulse AI - pronto para Vercel

## Deploy na Vercel
1. Envie **esta pasta** para a Vercel.
2. Framework: **Vite**
3. Build command: `npm run build`
4. Output directory: `dist`

## Variáveis de ambiente na Vercel
Adicione estas duas variáveis:
- `VITE_SUPABASE_URL`
- `VITE_SUPABASE_ANON_KEY`

Os mesmos valores já estão no arquivo `.env` para teste local.

## SQL do Supabase
Cole o conteúdo de `supabase.sql` no SQL Editor do seu projeto Supabase.

## Teste local
```bash
npm install
npm run dev
```
