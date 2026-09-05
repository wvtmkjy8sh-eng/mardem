/*
 * Ponte opcional para a infraestrutura Supabase.
 * Nesta primeira etapa ela NÃO substitui o login/localStorage existente.
 * Serve para validar a conexão e preparar a migração para o banco.
 */
(function(){
  const cfg = window.CICLOFIT_CLOUD_CONFIG || {};
  const ready = !!(cfg.enabled && cfg.supabaseUrl && cfg.supabaseKey && window.supabase);
  let client = null;
  if (ready) {
    try {
      client = window.supabase.createClient(cfg.supabaseUrl, cfg.supabaseKey);
    } catch (e) {
      console.warn('CicloFit Cloud: falha ao inicializar Supabase', e);
    }
  }
  window.CicloFitCloud = {
    enabled: ready,
    client,
    async ping(){
      if(!client) return {ok:false, reason:'disabled'};
      const { error } = await client.from('app_health').select('id').limit(1);
      return {ok:!error, error:error||null};
    },
    async saveState(scopeKey, payload){
      if(!client) return {ok:false, reason:'disabled'};
      const { error } = await client.from('app_state').upsert({scope_key:String(scopeKey),payload,updated_at:new Date().toISOString()},{onConflict:'scope_key'});
      return {ok:!error,error:error||null};
    },
    async loadState(scopeKey){
      if(!client) return {ok:false, reason:'disabled'};
      const { data, error } = await client.from('app_state').select('payload,updated_at').eq('scope_key',String(scopeKey)).maybeSingle();
      return {ok:!error,data:data||null,error:error||null};
    }
  };
})();
