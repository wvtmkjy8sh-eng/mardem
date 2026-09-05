/* Ponte do CicloFit para o Supabase.
 * A camada de autenticação usa somente credenciais públicas no browser.
 */
(function(){
  const cfg = window.CICLOFIT_CLOUD_CONFIG || {};
  const ready = !!(cfg.enabled && cfg.supabaseUrl && cfg.supabaseKey && window.supabase);
  let client = null;
  if (ready) {
    try { client = window.supabase.createClient(cfg.supabaseUrl, cfg.supabaseKey); }
    catch (e) { console.warn('CicloFit Cloud: falha ao inicializar Supabase', e); }
  }
  window.CicloFitCloud = {
    enabled: !!client,
    client,
    async getSession(){
      if(!client) return {session:null,error:new Error('Supabase desativado')};
      return await client.auth.getSession();
    },
    async signIn(email,password){
      if(!client) return {data:null,error:new Error('Supabase desativado')};
      return await client.auth.signInWithPassword({email,password});
    },
    async signOut(){
      if(!client) return {error:null};
      return await client.auth.signOut();
    },
    async getProfile(userId){
      if(!client) return {data:null,error:new Error('Supabase desativado')};
      return await client.from('profiles').select('*').eq('id',userId).maybeSingle();
    },
    async ping(){
      if(!client) return {ok:false, reason:'disabled'};
      const { error } = await client.from('app_health').select('id').limit(1);
      return {ok:!error,error:error||null};
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
