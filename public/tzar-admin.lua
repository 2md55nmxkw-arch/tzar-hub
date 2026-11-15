-- TZAR Hub Admin 1.0.0 · https://hub.2md.space/tzar-admin.lua
local __DARKLUA_BUNDLE_MODULES={cache={}}do do local function __modImpl()local CoreGui=game:GetService('CoreGui')local
HttpService=game:GetService('HttpService')local Players=game:GetService('Players')local Env={}local CAP_NAMES=table.
freeze({'getgenv','gethui','writefile','readfile','isfile','isfolder','makefolder','request','setclipboard',
'getcustomasset','sethiddenproperty','gethiddenproperty','getconnections','queue_on_teleport','identifyexecutor',
'cloneref'})Env.CAP_NAMES=CAP_NAMES local globals={getgenv=getgenv,gethui=gethui,writefile=writefile,readfile=readfile,
isfile=isfile,isfolder=isfolder,makefolder=makefolder,request=request,setclipboard=setclipboard,getcustomasset=
getcustomasset,sethiddenproperty=sethiddenproperty,gethiddenproperty=gethiddenproperty,getconnections=getconnections,
queue_on_teleport=queue_on_teleport,identifyexecutor=identifyexecutor,cloneref=cloneref}local caps={}for _,name in
CAP_NAMES do caps[name]=type(globals[name])=='function'end Env.caps=table.freeze(caps)local function fn(name)return if
caps[name]then globals[name]else nil end function Env.has(name)return caps[name]==true end function Env.genv()local g=
fn('getgenv')if g then local ok,t=pcall(g)if ok and type(t)=='table'then return t end end return _G end function Env.
guiParent()local h=fn('gethui')if h then local ok,parent=pcall(h)if ok and typeof(parent)=='Instance'then return parent
end end local ok=pcall(function()local probe=Instance.new('Folder')probe.Parent=CoreGui probe:Destroy()end)if ok then
return CoreGui end local lp=Players.LocalPlayer return lp:WaitForChild('PlayerGui')end function Env.readFile(path)local
isfile,readfile=fn('isfile'),fn('readfile')if not(isfile and readfile)then return nil end local ok,exists=pcall(isfile,
path)if not ok or not exists then return nil end local ok2,body=pcall(readfile,path)return if ok2 and type(body)==
'string'then body else nil end local function ensureFolder(path)local isfolder,makefolder=fn('isfolder'),fn('makefolder'
)if not(isfolder and makefolder)then return end local acc=''for part in string.gmatch(path,'[^/]+')do acc=if acc==''then
part else acc..'/'..part local ok,exists=pcall(isfolder,acc)if ok and not exists then pcall(makefolder,acc)end end end
function Env.writeFile(path,body)local writefile=fn('writefile')if not writefile then return false end local dir=string.
match(path,'^(.*)/[^/]+$')if dir then ensureFolder(dir)end return(pcall(writefile,path,body))end function Env.clipboard(
text)local set=fn('setclipboard')return if set then(pcall(set,text))else false end function Env.http(url,method)local
req=fn('request')if req then local ok,res=pcall(req,{Url=url,Method=method or'GET'})if ok and type(res)=='table'then
local status=tonumber(res.StatusCode)or 0 return{ok=status>=200 and status<300,status=status,body=tostring(res.Body or''
)}end return nil end local ok,body=pcall(function()return(game):HttpGet(url)end)return if ok then{ok=true,status=200,
body=body}else nil end function Env.json(body)local ok,v=pcall(HttpService.JSONDecode,HttpService,body)return if ok then
v else nil end function Env.executor()local id=fn('identifyexecutor')if id then local ok,name,ver=pcall(id)if ok then
return tostring(name or'?'),tostring(ver or'')end end return'Unknown',''end function Env.exists(path)local isfile=fn(
'isfile')if not isfile then return false end local ok,yes=pcall(isfile,path)return ok and yes==true end function Env.
customAsset(path)local get=fn('getcustomasset')if not get or not Env.exists(path)then return nil end local ok,id=pcall(
get,path)return if ok and type(id)=='string'then id else nil end function Env.getHidden(inst,prop)local get=fn(
'gethiddenproperty')if not get then return nil end local ok,v=pcall(get,inst,prop)return if ok then v else nil end
function Env.setHidden(inst,prop,value)local set=fn('sethiddenproperty')return if set then(pcall(set,inst,prop,value))
else false end function Env.queueOnTeleport(source)local q=fn('queue_on_teleport')return if q then(pcall(q,source))else
false end return Env end function __DARKLUA_BUNDLE_MODULES.a()local v=__DARKLUA_BUNDLE_MODULES.cache.a if not v then v={
c=__modImpl()}__DARKLUA_BUNDLE_MODULES.cache.a=v end return v.c end end do local function __modImpl()local Signal={}
Signal.__index=Signal local Conn={}Conn.__index=Conn function Conn.Disconnect(self)if not self.Connected then return end
self.Connected=false local list=self._signal._listeners for i=#list,1,-1 do if list[i].conn==self then table.remove(list
,i)break end end end function Signal.new(onError)local self={_listeners={},_onError=onError}return((setmetatable(self,
Signal)))end function Signal.Connect(self,fn)local conn=((setmetatable({Connected=true,_signal=self},Conn)))table.
insert(self._listeners,{fn=fn,conn=conn})return conn end function Signal.Fire(self,...)local list=self._listeners local
onError=self._onError for i=#list,1,-1 do local l=list[i]if l then local ok,err=pcall(l.fn,...)if not ok and onError
then onError(tostring(err))end end end end function Signal.DisconnectAll(self)for _,l in self._listeners do l.conn.
Connected=false end table.clear(self._listeners)end return Signal end function __DARKLUA_BUNDLE_MODULES.b()local v=
__DARKLUA_BUNDLE_MODULES.cache.b if not v then v={c=__modImpl()}__DARKLUA_BUNDLE_MODULES.cache.b=v end return v.c end
end do local function __modImpl()return nil end function __DARKLUA_BUNDLE_MODULES.c()local v=__DARKLUA_BUNDLE_MODULES.
cache.c if not v then v={c=__modImpl()}__DARKLUA_BUNDLE_MODULES.cache.c=v end return v.c end end do local function 
__modImpl()local LocalizationService=game:GetService('LocalizationService')local Signal=__DARKLUA_BUNDLE_MODULES.b()
local Types=__DARKLUA_BUNDLE_MODULES.c()local LANGS={'ru','en','uk','es','pt','de'}local function isLang(s)return s~=nil
and table.find(LANGS,s)~=nil end local function slavic(n)local m10,m100=n%10,n%100 if m10==1 and m100~=11 then return 1
elseif m10>=2 and m10<=4 and(m100<12 or m100>14)then return 2 end return 3 end local I18n={}I18n.__index=I18n I18n.LANGS
=LANGS function I18n.detect(saved)if isLang(saved)then return saved end local ok,locale=pcall(function()return
LocalizationService.RobloxLocaleId end)local code=if ok and type(locale)=='string'then string.sub(locale,1,2)else'en'
return if isLang(code)then code else'en'end function I18n.new(lang)local self={lang=lang,Changed=Signal.new(),_tables={}
}for _,l in LANGS do self._tables[l]={}end return((setmetatable(self,I18n)))end function I18n.Register(self,bundle)for
lang,strings in bundle do local into=self._tables[lang]if into then for k,v in strings do into[k]=v end end end end
local function lookup(self,key)return self._tables[self.lang][key]or self._tables.en[key]end function I18n.Has(self,key)
return lookup(self,key)~=nil end function I18n.T(self,key,...)local v=lookup(self,key)if v==nil then return key end if
type(v)=='table'and type((...))=='number'then return self:Plural(key,(...))end local s=if type(v)=='table'then v[#v]else
v if select('#',...)>0 then local ok,out=pcall(string.format,s,...)return if ok then out else s end return s end
function I18n.Plural(self,key,n)local v=lookup(self,key)if type(v)~='table'then return self:T(key,n)end local lang=if
self._tables[self.lang][key]then self.lang else'en'local idx if lang=='ru'or lang=='uk'then idx=slavic(math.abs(n))else
idx=if n==1 then 1 else 2 end local form=v[math.min(idx,#v)]local ok,out=pcall(string.format,form,n)return if ok then
out else form end function I18n.SetLang(self,lang)if not isLang(lang)then return false end self.lang=lang self.Changed:
Fire(lang)return true end function I18n.Destroy(self)self.Changed:DisconnectAll()end return I18n end function
__DARKLUA_BUNDLE_MODULES.d()local v=__DARKLUA_BUNDLE_MODULES.cache.d if not v then v={c=__modImpl()}
__DARKLUA_BUNDLE_MODULES.cache.d=v end return v.c end end do local function __modImpl()local Signal=
__DARKLUA_BUNDLE_MODULES.b()local CAPACITY=300 local Log={}Log.__index=Log function Log.new()local self={Added=Signal.
new(),_buf=(table.create(CAPACITY)),_head=0,_size=0}return((setmetatable(self,Log)))end function Log.Write(self,level,
text)local e={time=os.time(),level=level,text=text}self._head=self._head%CAPACITY+1 self._buf[self._head]=e self._size=
math.min(self._size+1,CAPACITY)if level=='error'then warn('[TZAR] '..text)end self.Added:Fire(e)end function Log.Info(
self,text)self:Write('info',text)end function Log.Warn(self,text)self:Write('warn',text)end function Log.Error(self,text
)self:Write('error',text)end function Log.Entries(self)local out={}local start=(self._head-self._size)%CAPACITY for i=1,
self._size do out[i]=self._buf[(start+i-1)%CAPACITY+1]end return out end function Log.Destroy(self)self.Added:
DisconnectAll()end return Log end function __DARKLUA_BUNDLE_MODULES.e()local v=__DARKLUA_BUNDLE_MODULES.cache.e if not v
then v={c=__modImpl()}__DARKLUA_BUNDLE_MODULES.cache.e=v end return v.c end end do local function __modImpl()local Fuzzy
={}local SCORE=table.freeze({EXACT=1000,PREFIX=400,CHAR=10,CONSECUTIVE=15,WORD_START=25,GAP=-1,LENGTH=-0.5})local 
function isBoundary(prev)return prev==' 'or prev=='_'or prev=='-'or prev=='.'or prev=='@'end function Fuzzy.score(query,
target,marks)if query==''then return 0 end local q,t=string.lower(query),string.lower(target)if q==t then if marks then
for i=1,#t do marks[i]=i end end return SCORE.EXACT end local score=0 local ti=1 local last=0 for qi=1,#q do local c=
string.sub(q,qi,qi)local found=string.find(t,c,ti,true)if not found then return nil end score+=SCORE.CHAR if found==last
+1 then score+=SCORE.CONSECUTIVE elseif last>0 then score+=SCORE.GAP*(found-last-1)end if found==1 or isBoundary(string.
sub(t,found-1,found-1))then score+=SCORE.WORD_START end if marks then marks[qi]=found end last=found ti=found+1 end if
string.sub(t,1,#q)==q then score+=SCORE.PREFIX end return score+SCORE.LENGTH*(#t-#q)end function Fuzzy.distance(a,b)a,b=
string.lower(a),string.lower(b)local n,m=#a,#b if n==0 then return m elseif m==0 then return n end local prev2={}local
prev={}for j=0,m do prev[j]=j end for i=1,n do local cur={[0]=i}local ai=string.byte(a,i)for j=1,m do local bj=string.
byte(b,j)local cost=if ai==bj then 0 else 1 local v=math.min(prev[j]+1,cur[j-1]+1,prev[j-1]+cost)if i>1 and j>1 and ai==
string.byte(b,j-1)and string.byte(a,i-1)==bj then v=math.min(v,prev2[j-2]+1)end cur[j]=v end prev2,prev=prev,cur end
return prev[m]end return Fuzzy end function __DARKLUA_BUNDLE_MODULES.f()local v=__DARKLUA_BUNDLE_MODULES.cache.f if not
v then v={c=__modImpl()}__DARKLUA_BUNDLE_MODULES.cache.f=v end return v.c end end do local function __modImpl()local
Players=game:GetService('Players')local Fuzzy=__DARKLUA_BUNDLE_MODULES.f()local PlayerFind={}local SCORE_ME=2000 local 
function scoreField(query,text,marks)local q,t=string.lower(query),string.lower(text)local at=string.find(t,q,1,true)if
at then for i=1,#q do marks[i]=at+i-1 end local bonus=if at==1 then 600 else 300 return bonus-#t end return Fuzzy.score(
query,text,marks)end function PlayerFind.search(query,includeSelf)local lp=Players.LocalPlayer local hits={}local q=
string.gsub(query,'^@','')for _,p in Players:GetPlayers()do if p==lp and not includeSelf then continue end if q==''then
local hit={player=p,score=0,why='name',marksName={},marksDisplay={}}table.insert(hits,hit)continue end local mn,md={},{}
local sn=scoreField(q,p.Name,mn)local sd=if p.DisplayName~=p.Name then scoreField(q,p.DisplayName,md)else nil if sn or
sd then local useDisplay=sd~=nil and(sn==nil or(sd)>(sn))local hit={player=p,score=if useDisplay then sd else sn,why=if
useDisplay then'display'else'name',marksName=if useDisplay then{}else mn,marksDisplay=if useDisplay then md else{}}table
.insert(hits,hit)end end if includeSelf and(q=='me'or q=='')then for _,h in hits do if h.player==lp then h.score=
SCORE_ME h.why='me'end end end table.sort(hits,function(a,b)if a.score~=b.score then return a.score>b.score end return a
.player.Name<b.player.Name end)return hits end function PlayerFind.resolve(query,includeSelf)local lp=Players.
LocalPlayer local q=string.lower((string.gsub(query,'^@','')))if q=='me'then return lp end for _,p in Players:
GetPlayers()do if string.lower(p.Name)==q and(includeSelf or p~=lp)then return p end end for _,p in Players:GetPlayers()
do if string.lower(p.DisplayName)==q and(includeSelf or p~=lp)then return p end end local hits=PlayerFind.search(q,
includeSelf)return if hits[1]then hits[1].player else nil end return PlayerFind end function __DARKLUA_BUNDLE_MODULES.g(
)local v=__DARKLUA_BUNDLE_MODULES.cache.g if not v then v={c=__modImpl()}__DARKLUA_BUNDLE_MODULES.cache.g=v end return v
.c end end do local function __modImpl()local Fuzzy=__DARKLUA_BUNDLE_MODULES.f()local PlayerFind=
__DARKLUA_BUNDLE_MODULES.g()local Types=__DARKLUA_BUNDLE_MODULES.c()local Args={}local TRUE_WORDS=table.freeze({'on',
'true','1','yes','\u{432}\u{43a}\u{43b}','\u{434}\u{430}','\u{443}\u{432}\u{456}\u{43c}\u{43a}','\u{442}\u{430}\u{43a}',
's\u{ed}','si','sim','ligado','an','ein','ja'})local FALSE_WORDS=table.freeze({'off','false','0','no',
'\u{432}\u{44b}\u{43a}\u{43b}','\u{43d}\u{435}\u{442}','\u{432}\u{438}\u{43c}\u{43a}','\u{43d}\u{456}','n\u{e3}o','nao',
'desligado','aus','nein'})function Args.parseBool(token)local t=string.lower(token)if table.find(TRUE_WORDS,t)then
return true elseif table.find(FALSE_WORDS,t)then return false end return nil end function Args.tokenize(line)local out={
}local i,n=1,#line while i<=n do local c=string.sub(line,i,i)if c==' 'or c=='\t'then i+=1 elseif c=='"'then local close=
string.find(line,'"',i+1,true)local stop=close or(n+1)table.insert(out,string.sub(line,i+1,stop-1))i=stop+1 else local
stop=string.find(line,'[ \t]',i)or(n+1)table.insert(out,string.sub(line,i,stop-1))i=stop end end local trailing=n>0 and
string.match(string.sub(line,n,n),'%s')~=nil return out,trailing end local function keyFromName(token)local lower=string
.lower(token)for _,item in Enum.KeyCode:GetEnumItems()do if string.lower(item.Name)==lower then return item end end
return nil end Args.keyFromName=keyFromName local function pickName(list,token)local lower=string.lower(token)for _,name
in list do if string.lower(name)==lower then return name end end local best,bestScore=nil,-math.huge for _,name in list
do local s=Fuzzy.score(token,name)if s and s>bestScore then best,bestScore=name,s end end return best end function Args.
parse(spec,token,ctx)local kind=spec.kind if kind=='string'or kind=='rest'then return token,nil elseif kind=='number'
then local n=tonumber(token)local lo,hi=spec.min or-math.huge,spec.max or math.huge if not n or n~=n or n<lo or n>hi
then return nil,ctx.t('arg.number',spec.min or'-\u{221e}',spec.max or'\u{221e}')end return n,nil elseif kind=='boolean'
then local b=Args.parseBool(token)if b==nil then return nil,ctx.t('arg.boolean')end return b,nil elseif kind=='enum'then
local opts=spec.options or{}local found=pickName(opts,token)if not found or not string.find(string.lower(found),string.
lower(token),1,true)then return nil,ctx.t('arg.enum',table.concat(opts,', '))end return found,nil elseif kind=='player'
then local p=PlayerFind.resolve(token,true)if not p then return nil,ctx.t('arg.player',token)end return p,nil elseif
kind=='user'then if string.match(token,'^%d+$')then local exact=game:GetService('Players'):FindFirstChild(token)return
if exact and exact:IsA('Player')then exact else token,nil end local p=PlayerFind.resolve(token,true)return p or token,
nil elseif kind=='key'then local k=keyFromName(token)if not k then return nil,ctx.t('arg.key',token)end return k,nil
elseif kind=='emote'and string.match(token,'^%d+$')then return token,nil else local found=pickName(ctx.list(kind),token)
if not found then return nil,ctx.t('arg.'..kind,token)end return found,nil end end local function playerSuggestions(
query,ctx)local out={}for _,h in PlayerFind.search(query,true)do local p=h.player table.insert(out,{text=p.Name,label=p.
DisplayName,sub='@'..p.Name,why=if h.why=='display'then ctx.t('ui.why.display')elseif h.why=='me'then ctx.t('ui.why.me')
else ctx.t('ui.why.name'),marks=h.marksDisplay,subMarks=h.marksName,score=h.score,player=p})end return out end local 
function listSuggestions(list,query)local out={}for _,name in list do local marks={}local s=Fuzzy.score(query,name,marks
)if s then table.insert(out,{text=name,label=name,marks=marks,score=s})end end table.sort(out,function(a,b)return a.
score>b.score end)return out end function Args.suggest(spec,query,ctx)local kind=spec.kind if kind=='player'or kind==
'user'then return playerSuggestions(query,ctx)elseif kind=='boolean'then return listSuggestions({'on','off'},query)
elseif kind=='enum'then return listSuggestions(spec.options or{},query)elseif kind=='key'then if query==''then return{}
end local names={}for _,item in Enum.KeyCode:GetEnumItems()do table.insert(names,item.Name)end local out=
listSuggestions(names,query)for i=#out,9,-1 do out[i]=nil end return out elseif kind=='number'or kind=='string'or kind==
'rest'then return{}end return listSuggestions(ctx.list(kind),query)end return Args end function __DARKLUA_BUNDLE_MODULES
.h()local v=__DARKLUA_BUNDLE_MODULES.cache.h if not v then v={c=__modImpl()}__DARKLUA_BUNDLE_MODULES.cache.h=v end
return v.c end end do local function __modImpl()local Types=__DARKLUA_BUNDLE_MODULES.c()local Format={}function Format.
argLabel(a)local inner=a.name if a.kind=='number'and a.min and a.max then inner=string.format('%s\u{2013}%s',Format.
value(a.min),Format.value(a.max))elseif a.kind=='enum'and a.options then inner=table.concat(a.options,'|')end return if
a.optional then'['..inner..']'else'<'..inner..'>'end function Format.signature(spec,current,rich)local parts={spec.name}
for i,a in spec.args or{}do local s=Format.argLabel(a)if rich then s=string.gsub(string.gsub(s,'<','&lt;'),'>','&gt;')if
i==current then s='<u><font color="#ededed">'..s..'</font></u>'end end table.insert(parts,s)end return table.concat(
parts,' ')end function Format.value(v)if type(v)=='number'then if v==math.floor(v)then return tostring(math.floor(v))end
return string.format('%.1f',v)elseif typeof(v)=='Instance'then return(v).Name elseif typeof(v)=='EnumItem'then return(v)
.Name elseif v==nil then return'\u{2014}'end return tostring(v)end function Format.quote(s)return if string.find(s,'%s')
then'"'..s..'"'else s end function Format.requiredArg(spec)for i,a in spec.args or{}do if not a.optional then return a,i
end end return nil,0 end return Format end function __DARKLUA_BUNDLE_MODULES.i()local v=__DARKLUA_BUNDLE_MODULES.cache.i
if not v then v={c=__modImpl()}__DARKLUA_BUNDLE_MODULES.cache.i=v end return v.c end end do local function __modImpl()
local Janitor={}Janitor.__index=Janitor local function asTask(value)local item=value local t=typeof(item)if t==
'RBXScriptConnection'then return function()item:Disconnect()end elseif t=='Instance'then return function()item:Destroy()
end elseif t=='function'then return item elseif t=='thread'then return function()if coroutine.status(item)~='dead'then
pcall(task.cancel,item)end end elseif t=='table'then local obj=value if type(obj.Destroy)=='function'then return
function()(value):Destroy()end elseif type(obj.Disconnect)=='function'then return function()(value):Disconnect()end
elseif type(obj.Cleanup)=='function'then return function()(value):Cleanup()end end end error('Janitor: cannot own a '..t
)end function Janitor.new(onError)local self={_tasks={},_onError=onError or function(msg)warn('[TZAR] cleanup: '..msg)
end}return((setmetatable(self,Janitor)))end function Janitor.Add(self,item)table.insert(self._tasks,asTask(item))return
item end function Janitor.Defer(self,fn)table.insert(self._tasks,fn)end function Janitor.Connect(self,signal,fn)local
onError=self._onError local conn=signal:Connect(function(...)local ok,err=pcall(fn,...)if not ok then onError(tostring(
err))end end)table.insert(self._tasks,function()conn:Disconnect()end)return conn end function Janitor.Set(self,target,
prop,value)local old=(target)[prop];(target)[prop]=value table.insert(self._tasks,function()if target.Parent~=nil or
target==workspace.CurrentCamera then(target)[prop]=old end end)end function Janitor.Cleanup(self)local tasks=self._tasks
self._tasks={}for i=#tasks,1,-1 do local ok,err=pcall(tasks[i])if not ok then self._onError(tostring(err))end end end
function Janitor.Count(self)return#self._tasks end return Janitor end function __DARKLUA_BUNDLE_MODULES.j()local v=
__DARKLUA_BUNDLE_MODULES.cache.j if not v then v={c=__modImpl()}__DARKLUA_BUNDLE_MODULES.cache.j=v end return v.c end
end do local function __modImpl()local RunService=game:GetService('RunService')local Scheduler={}Scheduler.__index=
Scheduler local BIND_NAME='TZAR_Admin_Render'local function step(list,dt)for i=#list,1,-1 do local e=list[i]local ok,err
=pcall(e.fn,dt)if not ok then table.remove(list,i)if e.onError then task.spawn(e.onError,tostring(err))end end end end
function Scheduler.new()local self={_stepped={},_heartbeat={},_render={},_conns={},_bound=false}table.insert(self._conns
,RunService.PreSimulation:Connect(function(dt)if#self._stepped>0 then step(self._stepped,dt)end end))table.insert(self.
_conns,RunService.Heartbeat:Connect(function(dt)if#self._heartbeat>0 then step(self._heartbeat,dt)end end))RunService:
BindToRenderStep(BIND_NAME,Enum.RenderPriority.Camera.Value+1,function(dt)if#self._render>0 then step(self._render,dt)
end end)self._bound=true return((setmetatable(self,Scheduler)))end function Scheduler.Add(self,phase,fn,onError)local
list=if phase=='render'then self._render elseif phase=='stepped'then self._stepped else self._heartbeat local entry={fn=
fn,onError=onError}table.insert(list,entry)return function()local i=table.find(list,entry)if i then table.remove(list,i)
end end end function Scheduler.Count(self)return#self._stepped+#self._heartbeat+#self._render end function Scheduler.
Destroy(self)table.clear(self._stepped)table.clear(self._heartbeat)table.clear(self._render)for _,c in self._conns do c:
Disconnect()end table.clear(self._conns)if self._bound then RunService:UnbindFromRenderStep(BIND_NAME)self._bound=false
end end return Scheduler end function __DARKLUA_BUNDLE_MODULES.k()local v=__DARKLUA_BUNDLE_MODULES.cache.k if not v then
v={c=__modImpl()}__DARKLUA_BUNDLE_MODULES.cache.k=v end return v.c end end do local function __modImpl()local
HttpService=game:GetService('HttpService')local Env=__DARKLUA_BUNDLE_MODULES.a()local Signal=__DARKLUA_BUNDLE_MODULES.b(
)local PATH='TZAR/admin/settings.json'local SCHEMA=4 local PINS_DEFAULT=table.freeze({'fly','speed','noclip'})local
SAVE_DELAY=1 local HISTORY_MAX=50 local function defaults()return{schema=SCHEMA,lang=nil,toggleKey='RightShift',
paletteKey='Semicolon',disabled={},binds={},holdBinds={},history={},chatCommands=false,sound=true,pins=(table.clone(
PINS_DEFAULT)),dock=nil,panels={},modules={},emoteWheel=false}end local MIGRATIONS={[1]=function(raw)raw.window=nil raw.
fab=nil raw.tab=nil raw.pins=raw.pins or table.clone(PINS_DEFAULT)raw.panels=raw.panels or{}raw.holdBinds=raw.holdBinds
or{}return raw end,[2]=function(raw)raw.modules=raw.modules or{}return raw end,[3]=function(raw)raw.emoteWheel=raw.
emoteWheel==true return raw end}local function migrate(raw)if type(raw)~='table'then return nil end local v=tonumber(raw
.schema)or 0 if v>SCHEMA then return nil end while v<SCHEMA do local step=MIGRATIONS[v]if step then raw=step(raw)end v+=
1 raw.schema=v end local out=defaults()for k,def in out do local got=raw[k]if got~=nil and(def==nil or type(got)==type(
def))then(out)[k]=got end end for _,k in{'lang','dock'}do if raw[k]~=nil then(out)[k]=raw[k]end end if#out.history>
HISTORY_MAX then out.history=table.move(out.history,#out.history-HISTORY_MAX+1,#out.history,1,{})end return out end
local Store={}Store.__index=Store function Store.new()local data=defaults()local body=Env.readFile(PATH)if body then
local raw=Env.json(body)local ok=migrate(raw)if ok then data=ok else Env.writeFile(PATH..'.bak',body)end end local self=
{data=data,Changed=Signal.new(),_pending=nil}return((setmetatable(self,Store)))end function Store.Flush(self)if self.
_pending then pcall(task.cancel,self._pending)self._pending=nil end local ok,body=pcall(HttpService.JSONEncode,
HttpService,self.data)if ok then Env.writeFile(PATH,body)end end function Store.Save(self,key)if key then self.Changed:
Fire(key)end if self._pending then return end self._pending=task.delay(SAVE_DELAY,function()self._pending=nil self:
Flush()end)end function Store.Destroy(self)if self._pending then self:Flush()end self.Changed:DisconnectAll()end Store.
PATH=PATH Store.HISTORY_MAX=HISTORY_MAX Store._migrate=migrate return Store end function __DARKLUA_BUNDLE_MODULES.l()
local v=__DARKLUA_BUNDLE_MODULES.cache.l if not v then v={c=__modImpl()}__DARKLUA_BUNDLE_MODULES.cache.l=v end return v.
c end end do local function __modImpl()local I18n=__DARKLUA_BUNDLE_MODULES.d()local Janitor=__DARKLUA_BUNDLE_MODULES.j()
local Log=__DARKLUA_BUNDLE_MODULES.e()local Scheduler=__DARKLUA_BUNDLE_MODULES.k()local Store=__DARKLUA_BUNDLE_MODULES.
l()local Types=__DARKLUA_BUNDLE_MODULES.c()return nil end function __DARKLUA_BUNDLE_MODULES.m()local v=
__DARKLUA_BUNDLE_MODULES.cache.m if not v then v={c=__modImpl()}__DARKLUA_BUNDLE_MODULES.cache.m=v end return v.c end
end do local function __modImpl()local Players=game:GetService('Players')local Args=__DARKLUA_BUNDLE_MODULES.h()local
CtxTypes=__DARKLUA_BUNDLE_MODULES.m()local Env=__DARKLUA_BUNDLE_MODULES.a()local Fuzzy=__DARKLUA_BUNDLE_MODULES.f()local
Janitor=__DARKLUA_BUNDLE_MODULES.j()local Signal=__DARKLUA_BUNDLE_MODULES.b()local Types=__DARKLUA_BUNDLE_MODULES.c()
local Registry={}Registry.__index=Registry local USER_ERROR='\1'local function trace(err)local s=tostring(err)if string.
sub(s,1,1)==USER_ERROR then return s end return debug.traceback(s,2)end function Registry.fail(text)error(USER_ERROR..
text,0)end function Registry.new(specs,loaders,disabled)local byName={}for _,s in specs do assert(byName[s.name]==nil,
'duplicate command '..s.name)byName[s.name]=s for _,a in s.aliases or{}do assert(byName[a]==nil,'duplicate alias '..a)
byName[a]=s end end local self={specs=specs,StateChanged=Signal.new(),Ran=Signal.new(),_byName=byName,_loaders=loaders,
_impls={},_modJan=Janitor.new(),_state={},_disabled=disabled,_lists={},_ctx=nil,_respawnConn=nil}setmetatable(self,
Registry)self._respawnConn=Players.LocalPlayer.CharacterAdded:Connect(function(char)(self):_onRespawn(char)end)return(
self)end function Registry.SetCtx(self,ctx)self._ctx=ctx end function Registry.Get(self,name)return self._byName[string.
lower(name)]end function Registry.Resolve(self,word)local w=string.lower(word)local s=self._byName[w]if s then return s,
nil end if string.sub(w,1,2)=='un'then local base=self._byName[string.sub(w,3)]if base and base.kind~='action'then
return base,false end end return nil,nil end function Registry.IsActive(self,name)local st=self._state[name]return st~=
nil and st.active end function Registry.ActiveCount(self)local n=0 for _,st in self._state do if st.active then n+=1 end
end return n end function Registry.IsDisabled(self,name)return table.find(self._disabled,name)~=nil end function
Registry.SetDisabled(self,name,disabled)local i=table.find(self._disabled,name)if disabled and not i then table.insert(
self._disabled,name)self:Disable(name)elseif not disabled and i then table.remove(self._disabled,i)end self.StateChanged
:Fire(name,self:IsActive(name))end function Registry.Missing(_self,spec)for _,need in spec.needs or{}do if not Env.has(
need)then return need end end return nil end function Registry.Args(self,name)local st=self._state[name]return if st
then st.args else{}end function Registry.Value(self,name)local st=self._state[name]if st and st.active and st.args[1]~=
nil then return st.args[1]end local spec=self._byName[name]local impl=spec and self._impls[spec.module]local h=impl and
impl.handlers[name]local current=h and h.current local ctx=self._ctx if current and ctx then local ok,v=pcall(current,
ctx)if ok and v~=nil then return v end end return spec and spec.default end function Registry.SetList(self,kind,provider
)self._lists[kind]=provider end function Registry.List(self,kind)if kind=='command'then local out={}for _,s in self.
specs do table.insert(out,s.name)end return out end local p=self._lists[kind]if not p then for _,s in self.specs do for
_,a in s.args or{}do if a.kind==kind and not self._impls[s.module]then pcall(self._impl,self,s)p=self._lists[kind]break
end end if p then break end end if not p then return{}end end local ok,list=pcall(p)return if ok and type(list)=='table'
then list else{}end function Registry._impl(self,spec)local impl=self._impls[spec.module]if impl then return impl end
local loader=self._loaders[spec.module]assert(loader,'no module '..spec.module)local m=(loader)()self._impls[spec.module
]=m local ctx=self._ctx for kind,provider in m.lists or{}do self._lists[kind]=function()return provider(ctx)end end if m
.init then m.init(ctx,self._modJan)end return m end function Registry.Api(self,module)for _,s in self.specs do if s.
module==module then local ok,m=pcall(self._impl,self,s)return if ok then(m).api else nil end end return nil end function
Registry._setActive(self,name,st,active)local was=st.active st.active=active if was~=active then self.StateChanged:Fire(
name,active)end end function Registry.Disable(self,name)local st=self._state[name]if not st or not st.active then return
end local jan=st.jan st.jan=nil if jan then jan:Cleanup()end self:_setActive(name,st,false)end function Registry._enable
(self,spec,args)local name=spec.name local st=self._state[name]or{active=false,args={}}self._state[name]=st local was=st
.active if st.jan then st.jan:Cleanup()end local ctx=self._ctx local h=self:_impl(spec).handlers[name]local enable=h and
h.enable assert(enable,'no enable for '..name)local jan=Janitor.new(function(msg)ctx.log:Error(name..': '..msg)end)st.
jan=jan st.args=args local ok,err=xpcall(function()enable(ctx,args,jan)return nil end,trace)if not ok then st.jan=nil
jan:Cleanup()self:_setActive(name,st,false)error(err,0)end self:_setActive(name,st,true)if was then self.StateChanged:
Fire(name,true)end end function Registry._onRespawn(self,char)local ctx=self._ctx if not ctx then return end local list=
{}for name,st in self._state do local spec=self._byName[name]if st.active and spec.respawn then if st.jan then st.jan:
Cleanup()st.jan=nil end table.insert(list,spec)end end if#list==0 then return end task.spawn(function()char:
WaitForChild('Humanoid',10)char:WaitForChild('HumanoidRootPart',10)for _,spec in list do local st=self._state[spec.name]
if st and st.active and char.Parent then local ok,err=pcall(self._enable,self,spec,st.args)if not ok then ctx.log:Error(
spec.name..' (respawn): '..tostring(err))end end end end)end local function suggestName(self,word)local best,bestDist=
nil,math.max(1,math.floor(#word/3))for _,s in self.specs do local d=Fuzzy.distance(word,s.name)if d<=bestDist then best,
bestDist=s.name,d end end if best then return best end local bestScore=0 for _,s in self.specs do local sc=Fuzzy.score(
word,s.name)if sc and sc>bestScore then best,bestScore=s.name,sc end end return best end function Registry.Run(self,line
,source)local ctx=self._ctx local t=ctx.t local tokens=Args.tokenize(line)if#tokens==0 then return false,nil end local
word=(table.remove(tokens,1))local spec,forced=self:Resolve(word)if not spec then local near=suggestName(self,word)
return false,if near then t('err.unknown_near',word,near)else t('err.unknown',word)end local name=spec.name if self:
IsDisabled(name)then return false,t('err.disabled',name)end local missing=self:Missing(spec)if missing then return false
,t('err.needs',name,missing)end if spec.kind~='action'and forced==nil and tokens[1]then local b=Args.parseBool(tokens[1]
)if b~=nil and(spec.kind=='toggle'or b==false)then forced=b table.remove(tokens,1)end end if spec.kind=='value'and
forced==nil and#tokens==0 then forced=false end local argCtx={t=t,list=function(kind)return self:List(kind)end}local
values={}local given=0 for i,a in spec.args or{}do local token=tokens[i]if a.kind=='rest'and token then token=table.
concat(tokens,' ',i)end if token==nil or token==''then if not a.optional and forced~=false then return false,t('err.arg'
,name,t('arg.missing',a.name))end else local v,err=Args.parse(a,token,argCtx)if err then return false,t('err.arg',name,
err)end values[i]=v given+=1 end end if source=='palette'then local h=ctx.store.data.history if h[#h]~=line then table.
insert(h,line)if#h>50 then table.remove(h,1)end ctx.store:Save()end end local ok,err=xpcall(function()if spec.kind==
'action'then local h=self:_impl(spec).handlers[name]local run=h and h.run assert(run,'no run for '..name)run(ctx,values)
return nil end local active=self:IsActive(name)local target if forced~=nil then target=forced elseif spec.kind=='value'
then target=given>0 else target=not active or given>0 end if target then self:_enable(spec,values)local shown=values[1]
if spec.kind=='value'and shown~=nil then ctx.toast('ok',t('toast.value',t('c.'..name),tostring(shown)))else ctx.toast(
'ok',t('toast.on',t('c.'..name)))end elseif active then self:Disable(name)ctx.toast('info',t(if spec.kind=='value'then
'toast.reset'else'toast.off',t('c.'..name)))end return nil end,trace)self.Ran:Fire(name,ok)if not ok then local msg=
tostring(err)if string.sub(msg,1,1)==USER_ERROR then return false,string.sub(msg,2)end ctx.log:Error(name..': '..msg)
local short=string.match(msg,'^[^\n]*')or msg short=string.gsub(short,'^.-:%d+: ','')return false,t('err.failed',name,
short)end return true,nil end function Registry.Destroy(self)if self._respawnConn then self._respawnConn:Disconnect()end
for name in self._state do self:Disable(name)end self._modJan:Cleanup()self.StateChanged:DisconnectAll()self.Ran:
DisconnectAll()end return Registry end function __DARKLUA_BUNDLE_MODULES.n()local v=__DARKLUA_BUNDLE_MODULES.cache.n if
not v then v={c=__modImpl()}__DARKLUA_BUNDLE_MODULES.cache.n=v end return v.c end end do local function __modImpl()local
CtxTypes=__DARKLUA_BUNDLE_MODULES.m()local Janitor=__DARKLUA_BUNDLE_MODULES.j()local Registry=__DARKLUA_BUNDLE_MODULES.
n()local Signal=__DARKLUA_BUNDLE_MODULES.b()local Store=__DARKLUA_BUNDLE_MODULES.l()local Types=__DARKLUA_BUNDLE_MODULES
.c()local Modules={}Modules.__index=Modules local function trace(err)return debug.traceback(tostring(err),2)end function
Modules.new(specs,loaders,registry,store)local self={specs=specs,Changed=Signal.new(),_byId={},_features={},_state={},
_impls={},_loaders=loaders,_runs={},_reg=registry,_store=store,_ctx=nil,_conn=nil}for _,s in specs do self._byId[s.id]=s
local byFid={}for _,f in s.features do assert(byFid[f.id]==nil,'duplicate feature '..s.id..'.'..f.id)byFid[f.id]=f end
self._features[s.id]=byFid self._state[s.id]={}self._runs[s.id]={state='idle',status='',progress=0,startedAt=0,pausedAt=
0,pausedTotal=0}end setmetatable(self,Modules)self._conn=registry.StateChanged:Connect(function(name)for _,s in specs do
for _,f in s.features do if f.command==name then self.Changed:Fire(s.id,f.id)end end end end)return(self)end function
Modules.SetCtx(self,ctx)self._ctx=ctx end function Modules.Get(self,id)return self._byId[id]end function Modules.
Available(self)local out={}for _,s in self.specs do if not s.places or table.find(s.places,game.PlaceId)then table.
insert(out,s)end end return out end function Modules.Feature(self,mod,fid)local m=self._features[mod]return m and m[fid]
end function Modules.IsOn(self,mod,fid)local f=self:Feature(mod,fid)if not f then return false end if f.command then
return self._reg:IsActive(f.command)end local st=self._state[mod][fid]return st~=nil and st.on end function Modules.
Value(self,mod,fid)local f=self:Feature(mod,fid)if not f then return nil end if f.command then if f.kind=='toggle'then
return self._reg:IsActive(f.command)end return self._reg:Value(f.command)end local st=self._state[mod][fid]if st and st.
on then return st.value end if f.kind=='toggle'then return false elseif f.kind=='choice'then return f.options and f.
options[1]end return f.default end function Modules._impl(self,mod)local cached=self._impls[mod]if cached then return
cached end local loader=self._loaders[mod]if not loader then error('no module '..mod)end local impl=loader()self._impls[
mod]=impl return impl end function Modules.Set(self,mod,fid,value)local f=self:Feature(mod,fid)if not f then return
false,'no feature '..mod..'.'..fid end local feature=f local off=value==nil or value==false if feature.command then
local cmd=feature.command local line if feature.kind=='toggle'then line=cmd..(if off then' off'else' on')elseif off then
line='un'..cmd else line=cmd..' '..tostring(value)end return self._reg:Run(line,'module')end local states=self._state[
mod]local st=states[fid]or{on=false,value=nil,jan=nil}states[fid]=st local old=st.jan if old then st.jan=nil old:
Cleanup()end if off then local was=st.on st.on=false st.value=nil if was then self.Changed:Fire(mod,fid)end return true,
nil end local ctx=self._ctx local handler=self:_impl(mod).features[fid]if not handler then return false,
'no handler for '..mod..'.'..fid end local jan=Janitor.new(function(msg)ctx.log:Error(mod..'.'..fid..': '..msg)end)local
ok,err=xpcall(function()handler.enable(ctx,value,jan)return nil end,trace)if not ok then jan:Cleanup()st.on=false st.
value=nil ctx.log:Error(mod..'.'..fid..': '..tostring(err))self.Changed:Fire(mod,fid)return false,string.match(tostring(
err),'^[^\n]*')end st.on=true st.value=value st.jan=jan self.Changed:Fire(mod,fid)return true,nil end function Modules.
SetSection(self,mod,section,on)local spec=self._byId[mod]if not spec then return end for _,f in spec.features do if f.
section==section then if on and f.kind=='toggle'then self:Set(mod,f.id,true)elseif not on and self:IsOn(mod,f.id)then
self:Set(mod,f.id,nil)end end end end function Modules.AllOff(self,mod)local spec=self._byId[mod]if not spec then return
end for _,f in spec.features do if self:IsOn(mod,f.id)then self:Set(mod,f.id,nil)end end end function Modules.Count(self
,mod,section)local spec=self._byId[mod]if not spec then return 0,0 end local on,total=0,0 for _,f in spec.features do if
not section or f.section==section then total+=1 if self:IsOn(mod,f.id)then on+=1 end end end return on,total end local 
function userEntry(store,mod)local all=store.data.modules all[mod]=all[mod]or{presets={}}return all[mod]end function
Modules.Presets(self,mod)local out={}local spec=self._byId[mod]if not spec then return out end for _,p in spec.presets
or{}do table.insert(out,{id=p.id,values=p.values,builtin=true})end for _,p in userEntry(self._store,mod).presets do
table.insert(out,{id=p.id,name=p.name,values=p.values,builtin=false})end return out end local function findPreset(self,
mod,presetId)for _,p in(self:Presets(mod))do if p.id==presetId then return p end end return nil end local function 
matches(self,mod,fid,want)local f=self:Feature(mod,fid)if not f then return true end if f.kind=='toggle'then return self
:IsOn(mod,fid)==(want==true)end if want==nil or want==false then return not self:IsOn(mod,fid)end return self:IsOn(mod,
fid)and tostring(self:Value(mod,fid))==tostring(want)end function Modules.PresetActive(self,mod,presetId)local p=
findPreset(self,mod,presetId)if not p then return false end for fid,want in p.values do if not matches(self,mod,fid,want
)then return false end end return next(p.values)~=nil end function Modules.ApplyPreset(self,mod,presetId)local p=
findPreset(self,mod,presetId)if not p then return end for fid,want in p.values do if not matches(self,mod,fid,want)then
self:Set(mod,fid,want)end end self.Changed:Fire(mod,'presets')end function Modules.TogglePreset(self,mod,presetId)if not
self:PresetActive(mod,presetId)then self:ApplyPreset(mod,presetId)return end local p=(findPreset(self,mod,presetId))for
fid in p.values do if self:IsOn(mod,fid)then self:Set(mod,fid,nil)end end self.Changed:Fire(mod,'presets')end function
Modules.SavePreset(self,mod,name)local spec=self._byId[mod]local values={}for _,f in spec.features do if self:IsOn(mod,f
.id)then values[f.id]=if f.kind=='toggle'then true else self:Value(mod,f.id)end end local entry=userEntry(self._store,
mod)local id='u'..tostring(os.time())..tostring(#entry.presets+1)table.insert(entry.presets,{id=id,name=name,values=
values})self._store:Save('modules')self.Changed:Fire(mod,'presets')return id end function Modules.PresetTitle(self,mod,p
)if p.name then return p.name end local ctx=self._ctx return if ctx then ctx.t('m.'..mod..'.p.'..p.id)else p.id end
local function presetKey(mod,p)local tail=if p.builtin then p.id else string.gsub(string.lower(p.name or p.id),'%s+','-'
)return mod..'.'..tail end function Modules.PresetKey(_self,mod,p)return presetKey(mod,p)end function Modules.PresetKeys
(self)local out={}for _,s in(self:Available())do for _,p in(self:Presets(s.id))do table.insert(out,presetKey(s.id,p))end
end return out end function Modules.FindPreset(self,key)local want=string.lower(key)for _,s in(self:Available())do for _
,p in(self:Presets(s.id))do if string.lower(presetKey(s.id,p))==want then return s.id,p end end end return nil,nil end
function Modules.DeletePreset(self,mod,presetId)local entry=userEntry(self._store,mod)for i,p in entry.presets do if p.
id==presetId then table.remove(entry.presets,i)break end end self._store:Save('modules')self.Changed:Fire(mod,'presets')
end function Modules.Run(self,mod)local r=self._runs[mod]return{state=r.state,status=r.status,progress=r.progress,
elapsed=function()if r.state=='idle'then return 0 end local now=if r.state=='paused'then r.pausedAt else os.clock()
return now-r.startedAt-r.pausedTotal end}end function Modules.Start(self,mod)local r=self._runs[mod]if r.state=='paused'
then r.pausedTotal+=os.clock()-r.pausedAt r.state='running'self.Changed:Fire(mod,'run')return end if r.state=='running'
then return end local impl=self:_impl(mod)local maybe=impl.run if not maybe then return end local routine=maybe local
ctx=self._ctx local jan=Janitor.new(function(msg)ctx.log:Error(mod..' run: '..msg)end)r.jan=jan r.state='running'r.
status=''r.progress=0 r.startedAt=os.clock()r.pausedTotal=0 local runner={status=function(text)r.status=text self.
Changed:Fire(mod,'run')end,progress=function(frac)r.progress=math.clamp(frac,0,1)self.Changed:Fire(mod,'run')end,wait=
function(seconds)local left=seconds while left>0 do if r.state=='idle'then return false end local dt=task.wait(math.min(
left,0.1))if r.state=='running'then left-=dt end end return r.state~='idle'end,value=function(fid)return self:Value(mod,
fid)end}self.Changed:Fire(mod,'run')r.thread=task.spawn(function()local ok,err=xpcall(function()routine(ctx,runner,jan)
return nil end,trace)if not ok then ctx.log:Error(mod..' run: '..tostring(err))ctx.toast('error',string.match(tostring(
err),'^[^\n]*')or tostring(err))end if r.jan==jan then jan:Cleanup()r.jan=nil r.thread=nil r.state='idle'r.progress=if
ok then r.progress else 0 self.Changed:Fire(mod,'run')end end)end function Modules.Pause(self,mod)local r=self._runs[mod
]if r.state=='running'then r.state='paused'r.pausedAt=os.clock()self.Changed:Fire(mod,'run')end end function Modules.
Stop(self,mod)local r=self._runs[mod]if r.state=='idle'then return end r.state='idle'local th=r.thread r.thread=nil if
th and coroutine.status(th)=='suspended'then pcall(task.cancel,th)end if r.jan then r.jan:Cleanup()r.jan=nil end r.
status=''r.progress=0 self.Changed:Fire(mod,'run')end function Modules.Destroy(self)if self._conn then self._conn:
Disconnect()end for _,s in self.specs do self:Stop(s.id)for _,st in self._state[s.id]do if st.jan then st.jan:Cleanup()
st.jan=nil end st.on=false end end self.Changed:DisconnectAll()end return Modules end function __DARKLUA_BUNDLE_MODULES.
o()local v=__DARKLUA_BUNDLE_MODULES.cache.o if not v then v={c=__modImpl()}__DARKLUA_BUNDLE_MODULES.cache.o=v end return
v.c end end do local function __modImpl()local Args=__DARKLUA_BUNDLE_MODULES.h()local Format=__DARKLUA_BUNDLE_MODULES.i(
)local Fuzzy=__DARKLUA_BUNDLE_MODULES.f()local Modules=__DARKLUA_BUNDLE_MODULES.o()local Registry=
__DARKLUA_BUNDLE_MODULES.n()local Types=__DARKLUA_BUNDLE_MODULES.c()local Analyze={}local MAX_COMMANDS=8 local
MAX_SUGGESTIONS=8 local MAX_RECENT=4 function Analyze.line(text,registry)local tokens,trailing=Args.tokenize(text)if#
tokens==0 then return{mode='home',query='',argIndex=0,tokens=tokens,trailing=trailing}end if#tokens==1 and not trailing
then return{mode='command',query=tokens[1],argIndex=0,tokens=tokens,trailing=trailing}end local spec=registry:Resolve(
tokens[1])if not spec then return{mode='unknown',query=tokens[1],argIndex=0,tokens=tokens,trailing=trailing}end local
first=2 if spec.kind=='toggle'and tokens[2]and Args.parseBool(tokens[2])~=nil and(trailing or#tokens>2)then first=3 end
local given=#tokens-first+1 local idx=if trailing then given+1 else math.max(given,1)local args=spec.args or{}local arg=
args[idx]if not arg and#args>0 and args[#args].kind=='rest'then arg=args[#args]idx=#args end return{mode='args',query=if
trailing then''else(tokens[#tokens]or''),spec=spec,argIndex=idx,arg=arg,tokens=tokens,trailing=trailing}end function
Analyze.commands(q,registry,t,extra)local found={}for _,item in extra or{}do table.insert(found,item)end local un=string
.sub(string.lower(q),1,2)=='un'and#q>2 for _,spec in registry.specs do if registry:IsDisabled(spec.name)then continue
end local marks={}local best=Fuzzy.score(q,spec.name,marks)local via=nil for _,a in spec.aliases or{}do local s=Fuzzy.
score(q,a)if s and(not best or s>best)then best,via,marks=s,a,{}end end if un and spec.kind~='action'then local m2={}
local s=Fuzzy.score(q,'un'..spec.name,m2)if s and(not best or s>best)then best,via,marks=s,nil,m2 table.insert(found,{
kind='command',text='un'..spec.name,label='un'..spec.name,sub=t('d.'..spec.name),marks=m2,score=s,spec=spec})continue
end end if best then table.insert(found,{kind='command',text=spec.name,label=spec.name,sub=t('d.'..spec.name),tag=via,
marks=marks,score=best,spec=spec})end end table.sort(found,function(a,b)return a.score>b.score end)local groups={}local
byCat={}for i,item in found do if i>MAX_COMMANDS then break end local cat=item.group or(item.spec).category local g=
byCat[cat]if not g then local fresh={title=item.group or t('cat.'..cat),items={}}byCat[cat]=fresh table.insert(groups,
fresh)g=fresh end table.insert((g).items,item)end return groups end local function moduleItem(s,registry,t,score)return{
kind='line',text='module '..s.id,label=t('m.'..s.id..'.title'),sub=t('m.'..s.id..'.desc'),score=score,spec=registry:Get(
'module'),group=t('sp.modules')}end function Analyze.modules(q,modules,registry,t)local out={}if registry:IsDisabled(
'module')or not registry:Get('module')then return out end local function best(...)local top=nil for _,s in{...}do local
v=Fuzzy.score(q,s)if v and(not top or v>top)then top=v end end return top end for _,s in modules:Available()do local
title=t('m.'..s.id..'.title')local score=best(s.id,title)if score then table.insert(out,moduleItem(s,registry,t,score))
end if registry:IsDisabled('preset')then continue end for _,p in modules:Presets(s.id)do local pt=modules:PresetTitle(s.
id,p)local key=modules:PresetKey(s.id,p)local ps=best(pt,p.id,key)if ps then table.insert(out,{kind='line',text=
'preset '..key,label=pt,sub=title,score=ps-1,spec=registry:Get('preset'),group=t('sp.modules')})end end end return out
end function Analyze.suggestions(a,registry,t)local arg=a.arg if not arg then return{}end local argCtx={t=t,list=
function(kind)return registry:List(kind)end}local items={}for i,s in Args.suggest(arg,a.query,argCtx)do if i>
MAX_SUGGESTIONS then break end table.insert(items,{kind=if s.player then'player'else'value',text=s.text,label=s.label,
sub=s.sub,tag=s.why,marks=s.marks,subMarks=s.subMarks,score=s.score,player=s.player})end if#items==0 then return{}end
local title=if arg.kind=='player'or arg.kind=='user'then t('sp.players')else arg.name return{{title=title,items=items}}
end function Analyze.home(registry,history,pins,t,modules)local groups={}local recent={}local seen={}for i=#history,1,-1
do local line=history[i]if not seen[line]then seen[line]=true local word=string.match(line,'^%S+')or line local spec=
registry:Resolve(word)if spec then table.insert(recent,{kind='line',text=line,label=line,score=0,spec=spec})end end if#
recent>=MAX_RECENT then break end end if#recent>0 then table.insert(groups,{title=t('sp.recent'),items=recent})end local
fav={}for _,name in pins do local spec=registry:Get(name)if spec and not registry:IsDisabled(name)then table.insert(fav,
{kind='command',text=spec.name,label=spec.name,sub=t('d.'..spec.name),score=0,spec=spec})end end if#fav>0 then table.
insert(groups,{title=t('sp.favorites'),items=fav})end if modules and registry:Get('module')and not registry:IsDisabled(
'module')then local mods={}for _,s in modules:Available()do table.insert(mods,moduleItem(s,registry,t,0))end if#mods>0
then table.insert(groups,{title=t('sp.modules'),items=mods})end end return groups end function Analyze.accept(text,a,
item)if a.mode=='home'then if not item then return text,false end local spec=item.spec if item.kind=='line'then return
item.text,true end local needs=spec and Format.requiredArg(spec)return item.text..(if needs then' 'else''),needs==nil
elseif a.mode=='command'then if not item then return text,true end if item.kind=='line'then return item.text,true end
local spec=item.spec local needs=spec and string.sub(item.text,1,2)~='un'and Format.requiredArg(spec)return item.text..(
if needs then' 'else''),not needs elseif a.mode=='args'then local spec=a.spec local line=text if item and a.arg then
line=string.sub(text,1,#text-#a.query)..Format.quote(item.text)end local lastReq=0 for i,arg in spec.args or{}do if not
arg.optional then lastReq=i end end local ready=a.argIndex>=lastReq if not ready then line..=' 'end return line,ready
end return text,true end return Analyze end function __DARKLUA_BUNDLE_MODULES.p()local v=__DARKLUA_BUNDLE_MODULES.cache.
p if not v then v={c=__modImpl()}__DARKLUA_BUNDLE_MODULES.cache.p=v end return v.c end end do local function __modImpl()
local Env=__DARKLUA_BUNDLE_MODULES.a()local Assets={}local BASE='https://hub.2md.space/tzar-assets/'local CACHE=
'TZAR/assets/'local LEGACY_IMAGES='AvatarChanger/assets/'local LEGACY_FONTS='AvatarChanger/fonts/'Assets.IMAGES=table.
freeze({'logo','settings','minus','x','search','arrow-right','refresh','teto','zap','ghost','gauge','arrow-up','clock',
'user','eye','sun','box','list','key','star','check','chevron-down','keyboard','map-pin','log-out','sparkles','plus',
'arrow-left','message','command','globe','menu','info'})Assets.FONTS=table.freeze({'Inter-Regular.ttf',
'Inter-Medium.ttf','Inter-SemiBold.ttf','Inter-ExtraBold.ttf','JetBrainsMono-Regular.ttf'})local ids={}function Assets.
path(file)if Env.exists(CACHE..file)then return CACHE..file end local legacy=(if string.sub(file,-4)=='.ttf'then
LEGACY_FONTS else LEGACY_IMAGES)..file if Env.exists(legacy)then return legacy end return nil end function Assets.image(
name)local cached=ids[name]if cached then return cached end local path=Assets.path(name..'.png')local id=path and Env.
customAsset(path)if id then ids[name]=id end return id end function Assets.missing()local out={}for _,name in Assets.
IMAGES do if not Assets.path(name..'.png')then table.insert(out,name..'.png')end end for _,file in Assets.FONTS do if
not Assets.path(file)then table.insert(out,file)end end return out end function Assets.download(files,done)if#files==0
or not Env.has('writefile')then return end task.spawn(function()local got=0 for _,file in files do local res=Env.http(
BASE..file)if res and res.ok and#res.body>0 and string.sub(res.body,1,1)~='<'then if Env.writeFile(CACHE..file,res.body)
then got+=1 end end end done(got)end)end return Assets end function __DARKLUA_BUNDLE_MODULES.q()local v=
__DARKLUA_BUNDLE_MODULES.cache.q if not v then v={c=__modImpl()}__DARKLUA_BUNDLE_MODULES.cache.q=v end return v.c end
end do local function __modImpl()local HttpService=game:GetService('HttpService')local UserInputService=game:GetService(
'UserInputService')local Assets=__DARKLUA_BUNDLE_MODULES.q()local Env=__DARKLUA_BUNDLE_MODULES.a()local Theme={}Theme.C=
table.freeze({base=Color3.fromHex('080808'),surface=Color3.fromHex('121212'),card=Color3.fromHex('161616'),raised=Color3
.fromHex('1a1a1a'),control=Color3.fromHex('232323'),hover=Color3.fromHex('2c2c2c'),track=Color3.fromHex('171717'),
trackHover=Color3.fromHex('1c1c1c'),text1=Color3.fromHex('ededed'),text2=Color3.fromHex('9a9a98'),text3=Color3.fromHex(
'5f5f5d'),accent=Color3.fromHex('e53945'),ok=Color3.fromHex('3ecf8e'),info=Color3.fromHex('5b9cf6'),white=Color3.new(1,1
,1),black=Color3.new(0,0,0)})Theme.LINE=table.freeze({default=0.9,subtle=0.94,strong=0.84})Theme.SIZE=table.freeze({bar=
600,barTouch=560,barTop=92,results=312,row=40,rowTouch=44,radius=8,card=12,window=16,panel=280,panelTouch=492})Theme.
touch=UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled local OUT_DIR='TZAR/admin/fonts/'local 
function family(name,faces)local t={name=name,faces={}}for _,f in faces do local path=Assets.path(f[3])local id=path and
Env.customAsset(path)if not id then return nil end table.insert(t.faces,{name=f[1],weight=f[2],style='normal',assetId=id
})end local path=OUT_DIR..name..'.json'if not Env.writeFile(path,HttpService:JSONEncode(t))then return nil end return
Env.customAsset(path)end local function pick(fam,fallback,weight)return if fam then Font.new(fam,weight)else Font.
fromName(fallback,weight)end Theme.F={}function Theme.loadFonts()local inter=family('Inter',{{'Regular',400,
'Inter-Regular.ttf'},{'Medium',500,'Inter-Medium.ttf'},{'SemiBold',600,'Inter-SemiBold.ttf'},{'ExtraBold',800,
'Inter-ExtraBold.ttf'}})local mono=family('JetBrainsMono',{{'Regular',400,'JetBrainsMono-Regular.ttf'}})local F=Theme.F
F.regular=pick(inter,'BuilderSans',Enum.FontWeight.Regular)F.medium=pick(inter,'BuilderSans',Enum.FontWeight.Medium)F.
semibold=pick(inter,'BuilderSans',Enum.FontWeight.SemiBold)F.bold=pick(inter,'BuilderSans',Enum.FontWeight.ExtraBold)F.
mono=pick(mono,'RobotoMono',Enum.FontWeight.Regular)end Theme.loadFonts()Theme.SHADOW=table.freeze({window={Color=Color3
.new(0,0,0),Transparency=0.4,Offset=UDim2.fromOffset(0,24),BlurRadius=UDim.new(0,64),Spread=UDim2.fromOffset(-8,-8)},pop
={Color=Color3.new(0,0,0),Transparency=0.45,Offset=UDim2.fromOffset(0,8),BlurRadius=UDim.new(0,24)}})return Theme end
function __DARKLUA_BUNDLE_MODULES.r()local v=__DARKLUA_BUNDLE_MODULES.cache.r if not v then v={c=__modImpl()}
__DARKLUA_BUNDLE_MODULES.cache.r=v end return v.c end end do local function __modImpl()local TweenService=game:
GetService('TweenService')local Theme=__DARKLUA_BUNDLE_MODULES.r()local C,F,LINE=Theme.C,Theme.F,Theme.LINE local Create
={}function Create.new(class,props,children)local inst=Instance.new(class)for k,v in props do if k~='Parent'then(inst)[k
]=v end end for _,child in children or{}do child.Parent=inst end if props.Parent then inst.Parent=props.Parent end
return inst end local new=Create.new function Create.corner(px)return new('UICorner',{CornerRadius=UDim.new(0,px)})end
function Create.stroke(transparency,color)return new('UIStroke',{Color=color or C.white,Transparency=transparency or
LINE.default,Thickness=1,ApplyStrokeMode=Enum.ApplyStrokeMode.Border})end function Create.pad(l,r,t,b)return new(
'UIPadding',{PaddingLeft=UDim.new(0,l),PaddingRight=UDim.new(0,r or l),PaddingTop=UDim.new(0,t or 0),PaddingBottom=UDim.
new(0,b or t or 0)})end function Create.list(dir,gap,align)return new('UIListLayout',{FillDirection=if dir=='x'then Enum
.FillDirection.Horizontal else Enum.FillDirection.Vertical,Padding=UDim.new(0,gap),SortOrder=Enum.SortOrder.LayoutOrder,
VerticalAlignment=align or(if dir=='x'then Enum.VerticalAlignment.Center else Enum.VerticalAlignment.Top)})end function
Create.text(p,extra)local props={BackgroundTransparency=1,Text=p.text,TextSize=p.size or 13,FontFace=p.font or F.regular
,TextColor3=p.color or C.text1,TextXAlignment=p.x or Enum.TextXAlignment.Left,TextYAlignment=Enum.TextYAlignment.Center,
TextTruncate=Enum.TextTruncate.AtEnd,RichText=true,AutoLocalize=false}if p.auto then props.AutomaticSize=Enum.
AutomaticSize.X props.Size=UDim2.fromScale(0,1)props.TextTruncate=Enum.TextTruncate.None end for k,v in extra or{}do
props[k]=v end return new('TextLabel',props)end function Create.shadow(parent,preset)local ok,s=pcall(function()return
Instance.new('UIShadow')end)if not ok then return end for k,v in preset do pcall(function()(s)[k]=v end)end s.Parent=
parent end function Create.fitScroll(sf,max)local layout=sf:FindFirstChildOfClass('UIListLayout')local padding=sf:
FindFirstChildOfClass('UIPadding')sf.AutomaticSize=Enum.AutomaticSize.None local function refit()local h=if layout then
layout.AbsoluteContentSize.Y else 0 if padding then h+=padding.PaddingTop.Offset+padding.PaddingBottom.Offset end local
x=sf.Size.X sf.Size=UDim2.new(x.Scale,x.Offset,0,math.floor(math.min(h,max())))end if layout then layout:
GetPropertyChangedSignal('AbsoluteContentSize'):Connect(refit)end refit()return refit end local TWEEN=TweenInfo.new(0.14
,Enum.EasingStyle.Quad,Enum.EasingDirection.Out)function Create.tween(inst,props,info)TweenService:Create(inst,info or
TWEEN,props):Play()end function Create.marked(text,marks)local function esc(s)return(string.gsub(string.gsub(string.
gsub(s,'&','&amp;'),'<','&lt;'),'>','&gt;'))end if not marks or#marks==0 then return esc(text)end local set={}for _,m in
marks do set[m]=true end local out={}local i,n=1,#text while i<=n do local j=i local on=set[i]==true while j+1<=n and(
set[j+1]==true)==on do j+=1 end local chunk=esc(string.sub(text,i,j))table.insert(out,if on then
'<u><font color="#ffffff">'..chunk..'</font></u>'else chunk)i=j+1 end return table.concat(out)end return Create end
function __DARKLUA_BUNDLE_MODULES.s()local v=__DARKLUA_BUNDLE_MODULES.cache.s if not v then v={c=__modImpl()}
__DARKLUA_BUNDLE_MODULES.cache.s=v end return v.c end end do local function __modImpl()local Assets=
__DARKLUA_BUNDLE_MODULES.q()local Create=__DARKLUA_BUNDLE_MODULES.s()local Theme=__DARKLUA_BUNDLE_MODULES.r()local C,F,
LINE,S=Theme.C,Theme.F,Theme.LINE,Theme.SIZE local new,corner,tween=Create.new,Create.corner,Create.tween local Controls
={}function Controls.switch(parent)local track=new('Frame',{Name='Switch',Size=UDim2.fromOffset(32,18),BackgroundColor3=
C.control,Parent=parent},{corner(9)})local knob=new('Frame',{Size=UDim2.fromOffset(14,14),Position=UDim2.fromOffset(2,2)
,BackgroundColor3=C.text2,Parent=track},{corner(7)})local function set(on)tween(track,{BackgroundColor3=if on then C.
accent else C.control})tween(knob,{Position=UDim2.fromOffset(if on then 16 else 2,2),BackgroundColor3=if on then C.white
else C.text2})end return{frame=track,set=set}end function Controls.glyph(name,parent,size,color)local px=size or 16
local id=Assets.image(name)if id then return new('ImageLabel',{Name='Icon',BackgroundTransparency=1,Size=UDim2.
fromOffset(px,px),Image=id,ImageColor3=color or C.text2,ScaleType=Enum.ScaleType.Fit,Parent=parent})end return Create.
text({text='\u{2022}',size=px,color=color or C.text2,x=Enum.TextXAlignment.Center},{Name='Icon',Size=UDim2.fromOffset(px
,px),Parent=parent})end function Controls.tint(icon,color)if icon:IsA('ImageLabel')then icon.ImageColor3=color elseif
icon:IsA('TextLabel')then icon.TextColor3=color end end function Controls.logo(parent,size)local id=Assets.image('logo')
if id then return new('ImageLabel',{Name='Logo',BackgroundTransparency=1,Size=UDim2.fromOffset(size,size),Image=id,
ScaleType=Enum.ScaleType.Fit,Parent=parent})end local box=new('Frame',{Name='Logo',BackgroundTransparency=1,Size=UDim2.
fromOffset(size,size),Parent=parent})local u=size/24 new('Frame',{Position=UDim2.fromOffset(3*u,4*u),Size=UDim2.
fromOffset(18*u,3.2*u),BackgroundColor3=C.accent,BorderSizePixel=0,Parent=box})new('Frame',{Position=UDim2.fromOffset(
10.4*u,7*u),Size=UDim2.fromOffset(3.2*u,13*u),BackgroundColor3=C.accent,BorderSizePixel=0,Parent=box})return box end
function Controls.kbd(parent,text)local k=Create.text({text=text,size=11,font=F.mono,color=C.text1,auto=true,x=Enum.
TextXAlignment.Center},{Name='Kbd',Size=UDim2.fromOffset(0,22),BackgroundTransparency=0,BackgroundColor3=C.control,
Parent=parent})corner(5).Parent=k Create.stroke(LINE.subtle).Parent=k Create.pad(7,7).Parent=k return k end local
BUTTON_BG={plain={C.control,0},accent={C.accent,0},ghost={C.surface,1},danger={C.accent,0.86}}function Controls.button(
parent,text,kind,icon)local k=kind or'plain'local bg=BUTTON_BG[k]local fg=if k=='accent'then C.white elseif k=='danger'
then C.accent else C.text1 local b=new('TextButton',{Name='Button',Text='',AutoButtonColor=false,AutomaticSize=Enum.
AutomaticSize.X,Size=UDim2.fromOffset(0,if Theme.touch then 38 else 32),BackgroundColor3=bg[1],BackgroundTransparency=bg
[2],Parent=parent},{corner(S.radius),Create.pad(12,12),Create.list('x',7)})if k=='ghost'then Create.stroke(LINE.strong).
Parent=b end if icon then Controls.glyph(icon,b,14,fg).LayoutOrder=1 end Create.text({text=text,size=13,font=F.medium,
color=fg,auto=true},{Name='Label',LayoutOrder=2,Parent=b})local base=b.BackgroundColor3 b.MouseEnter:Connect(function()
if k=='plain'then tween(b,{BackgroundColor3=C.hover})end end)b.MouseLeave:Connect(function()if k=='plain'then tween(b,{
BackgroundColor3=base})end end)return b end function Controls.iconButton(parent,icon,size,filled)local px=size or(if
Theme.touch then 34 else 28)local b=new('TextButton',{Name='IconButton',Text='',AutoButtonColor=false,Size=UDim2.
fromOffset(px,px),BackgroundColor3=C.control,BackgroundTransparency=if filled then 0 else 1,Parent=parent},{corner(S.
radius)})local g=Controls.glyph(icon,b,14,C.text2)g.AnchorPoint=Vector2.new(0.5,0.5)g.Position=UDim2.fromScale(0.5,0.5)b
.MouseEnter:Connect(function()tween(b,{BackgroundTransparency=0})end)b.MouseLeave:Connect(function()tween(b,{
BackgroundTransparency=if filled then 0 else 1})end)return b end function Controls.avatar(parent,userId,size)local a=
new('ImageLabel',{Name='Avatar',Size=UDim2.fromOffset(size,size),BackgroundColor3=C.control,Image=string.format(
'rbxthumb://type=AvatarHeadShot&id=%d&w=48&h=48',userId),ScaleType=Enum.ScaleType.Crop,Parent=parent},{corner(size//2)})
return a end function Controls.check(parent)local box=new('Frame',{Name='Check',Size=UDim2.fromOffset(18,18),
BackgroundColor3=C.control,Parent=parent},{corner(5)})local stroke=Create.stroke(LINE.default)stroke.Parent=box local
tick=Controls.glyph('check',box,12,C.white)tick.AnchorPoint=Vector2.new(0.5,0.5)tick.Position=UDim2.fromScale(0.5,0.5)
tick.Visible=false return{frame=box,set=function(on)box.BackgroundColor3=if on then C.accent else C.control stroke.
Enabled=not on tick.Visible=on end}end function Controls.eyebrow(parent,text)return Create.text({text='<uc>'..Create.
marked(text,nil)..'</uc>',size=10,font=F.medium,color=C.text3,auto=true},{Name='Eyebrow',Size=UDim2.fromOffset(0,16),
Parent=parent})end function Controls.hairline(parent,order)return new('Frame',{Name='Hairline',BackgroundColor3=C.white,
BackgroundTransparency=LINE.default,BorderSizePixel=0,Size=UDim2.new(1,0,0,1),LayoutOrder=order or 0,Parent=parent})end
return Controls end function __DARKLUA_BUNDLE_MODULES.t()local v=__DARKLUA_BUNDLE_MODULES.cache.t if not v then v={c=
__modImpl()}__DARKLUA_BUNDLE_MODULES.cache.t=v end return v.c end end do local function __modImpl()local
UserInputService=game:GetService('UserInputService')local Create=__DARKLUA_BUNDLE_MODULES.s()local Janitor=
__DARKLUA_BUNDLE_MODULES.j()local Theme=__DARKLUA_BUNDLE_MODULES.r()local C,F,S=Theme.C,Theme.F,Theme.SIZE local new,
corner,tween=Create.new,Create.corner,Create.tween local SLOP=6 local FILL_ON,LINE_ON=C.accent,Color3.fromHex('ff8a93')
local FILL_OFF,LINE_OFF=Color3.fromHex('3b1a1d'),Color3.fromHex('70343a')local FillBar={}function FillBar.new(parent,o)
local frame=new('TextButton',{Name='FillBar',Text='',AutoButtonColor=false,BackgroundTransparency=1,Size=UDim2.new(1,0,0
,o.height),Parent=parent})local track=new('CanvasGroup',{Name='Track',Size=UDim2.fromScale(1,1),BackgroundColor3=C.track
,BorderSizePixel=0,Parent=frame},{corner(S.radius)})local fill=new('Frame',{Name='Bar',Size=UDim2.fromScale(0,1),
BackgroundColor3=FILL_OFF,BorderSizePixel=0,Parent=track})local edge=new('Frame',{Name='Edge',AnchorPoint=Vector2.new(1,
0),Size=UDim2.new(0,2,1,0),BackgroundColor3=LINE_OFF,BorderSizePixel=0,Parent=track})local notch=nil if o.default then
notch=new('Frame',{Name='Default',AnchorPoint=Vector2.new(0.5,1),Size=UDim2.fromOffset(2,5),BackgroundColor3=C.white,
BackgroundTransparency=0.65,BorderSizePixel=0,ZIndex=2,Parent=track})end local label=Create.text({text=o.title(),size=13
,font=F.medium},{Name='Label',Position=UDim2.fromOffset(12,0),Size=UDim2.new(0.7,-12,1,0),ZIndex=2,Parent=frame})local
number=Create.text({text='',size=12.5,font=F.mono,x=Enum.TextXAlignment.Right},{Name='Value',AnchorPoint=Vector2.new(1,0
),Position=UDim2.new(1,-12,0,0),Size=UDim2.fromScale(0.3,1),ZIndex=2,Parent=frame})local function frac(v)if o.max<=o.min
then return 0 end return math.clamp((v-o.min)/(o.max-o.min),0,1)end if notch and o.default then notch.Position=UDim2.
fromScale(frac(o.default),1)end local hovering=false local isDragging=false local current=o.value()local function paint(
v,animate)local a=frac(v)local on=o.active()or isDragging local enabled=o.enabled()local fillProps={Size=UDim2.
fromScale(a,1),BackgroundColor3=if on then FILL_ON else FILL_OFF}local edgeProps={Position=UDim2.fromScale(a,0),
BackgroundColor3=if on then LINE_ON else LINE_OFF,Size=UDim2.new(0,if isDragging then 3 else 2,1,0)}if animate then
tween(fill,fillProps)tween(edge,edgeProps)else for k,val in fillProps do(fill)[k]=val end for k,val in edgeProps do(edge
)[k]=val end end edge.Visible=a>0.005 and a<0.995 track.BackgroundColor3=if hovering or isDragging then C.trackHover
else C.track track.GroupTransparency=if enabled then 0 else 0.6 number.Text=o.format(v)number.TextColor3=if on then C.
white else C.text2 label.TextColor3=if enabled then C.text1 else C.text3 end local function fromX(x)local left=track.
AbsolutePosition.X local width=math.max(track.AbsoluteSize.X,1)local v=o.min+math.clamp((x-left)/width,0,1)*(o.max-o.min
)v=math.floor(v/o.step+0.5)*o.step return math.clamp(v,o.min,o.max)end local press=nil local scrollWas=true o.jan:
Connect(frame.InputBegan,function(io)if not o.enabled()then return end local t=io.UserInputType if t==Enum.UserInputType
.MouseButton1 or t==Enum.UserInputType.Touch then press=io.Position isDragging=false elseif t==Enum.UserInputType.
MouseMovement and not hovering then hovering=true paint(current,true)end end)o.jan:Connect(frame.MouseLeave,function()
hovering=false if not isDragging then paint(current,true)end end)o.jan:Connect(UserInputService.InputChanged,function(io
)local p=press if not p then return end local t=io.UserInputType if t~=Enum.UserInputType.MouseMovement and t~=Enum.
UserInputType.Touch then return end local d=io.Position-p if not isDragging then if math.abs(d.Y)>SLOP and math.abs(d.Y)
>math.abs(d.X)then press=nil return end if math.abs(d.X)<=SLOP then return end isDragging=true if o.scroll then
scrollWas=o.scroll.ScrollingEnabled o.scroll.ScrollingEnabled=false end end local v=fromX(io.Position.X)if v~=current
then current=v paint(v,false)end end)o.jan:Connect(UserInputService.InputEnded,function(io)local p=press local t=io.
UserInputType if not p or(t~=Enum.UserInputType.MouseButton1 and t~=Enum.UserInputType.Touch)then return end local v=if
isDragging then current else fromX(p.X)press=nil isDragging=false if o.scroll then o.scroll.ScrollingEnabled=scrollWas
end current=v paint(v,true)o.commit(v)end)paint(current,false)return{frame=frame,refresh=function()if not isDragging
then current=o.value()label.Text=o.title()paint(current,true)end end,dragging=function()return isDragging end}end return
FillBar end function __DARKLUA_BUNDLE_MODULES.u()local v=__DARKLUA_BUNDLE_MODULES.cache.u if not v then v={c=__modImpl()
}__DARKLUA_BUNDLE_MODULES.cache.u=v end return v.c end end do local function __modImpl()local Analyze=
__DARKLUA_BUNDLE_MODULES.p()local Controls=__DARKLUA_BUNDLE_MODULES.t()local Create=__DARKLUA_BUNDLE_MODULES.s()local
FillBar=__DARKLUA_BUNDLE_MODULES.u()local Format=__DARKLUA_BUNDLE_MODULES.i()local Janitor=__DARKLUA_BUNDLE_MODULES.j()
local Modules=__DARKLUA_BUNDLE_MODULES.o()local Registry=__DARKLUA_BUNDLE_MODULES.n()local Store=
__DARKLUA_BUNDLE_MODULES.l()local Theme=__DARKLUA_BUNDLE_MODULES.r()local Types=__DARKLUA_BUNDLE_MODULES.c()local C,F,S=
Theme.C,Theme.F,Theme.SIZE local new,corner,pad,list=Create.new,Create.corner,Create.pad,Create.list local Rows={}
function Rows.argText(spec)local parts={}for _,a in spec.args or{}do table.insert(parts,Format.argLabel(a))end return
table.concat(parts,' ')end function Rows.keyFor(store,name)for key,line in store.data.binds do if line==name then return
key end end return nil end function Rows.group(parent,title,order)local f=new('Frame',{Name='Group',
BackgroundTransparency=1,Size=UDim2.new(1,0,0,24),LayoutOrder=order,Parent=parent},{pad(8,8,6,0)})Controls.eyebrow(f,
title)return f end local function base(parent,order,height,selected)return new('TextButton',{Name='Result',Text='',
AutoButtonColor=false,BackgroundColor3=C.control,BackgroundTransparency=if selected then 0 else 1,Size=UDim2.new(1,0,0,
height),LayoutOrder=order,Parent=parent},{corner(S.radius),pad(10,10)})end function Rows.command(parent,item,selected,
deps,order)local spec=item.spec local b=base(parent,order,46,selected)local top=new('Frame',{BackgroundTransparency=1,
Position=UDim2.fromOffset(0,7),Size=UDim2.new(1,0,0,18),Parent=b},{list('x',6)})if deps.registry:IsActive(spec.name)then
new('Frame',{Name='On',Size=UDim2.fromOffset(5,5),BackgroundColor3=C.accent,LayoutOrder=1,Parent=top},{corner(3)})end
Create.text({text=Create.marked(item.label,item.marks),size=13,font=F.medium,auto=true},{Name='Name',LayoutOrder=2,
Parent=top})local value=if spec.kind=='value'and deps.registry:IsActive(spec.name)then Format.value(deps.registry:Value(
spec.name))else Rows.argText(spec)Create.text({text=Create.marked(value,nil),size=10.5,font=F.mono,color=C.text3,auto=
true},{Name='Args',LayoutOrder=3,Parent=top})if item.tag then Create.text({text=item.tag,size=10,color=C.text3,x=Enum.
TextXAlignment.Right},{Name='Tag',AnchorPoint=Vector2.new(1,0),Position=UDim2.new(1,0,0,7),Size=UDim2.fromOffset(80,18),
Parent=b})end Create.text({text=item.sub or'',size=12,color=if selected then C.text2 else C.text3},{Name='Desc',Position
=UDim2.fromOffset(0,25),Size=UDim2.new(1,0,0,16),Parent=b})return b end function Rows.line(parent,item,selected,deps,
order)local b=base(parent,order,34,selected)list('x',8).Parent=b local spec=item.spec Controls.glyph((spec and spec.icon
)or'command',b,14,C.text3).LayoutOrder=1 Create.text({text=Create.marked(item.label,nil),size=12.5,font=if item.sub then
F.medium else F.mono,auto=true},{LayoutOrder=2,Parent=b})if item.sub then local sub=Create.text({text=Create.marked(item
.sub,nil),size=11.5,color=C.text3,auto=true},{LayoutOrder=4,TextTruncate=Enum.TextTruncate.AtEnd,Parent=b})new(
'UISizeConstraint',{MaxSize=Vector2.new(S.bar*0.45,math.huge),Parent=sub})end if spec and not item.group and deps.
registry:IsActive(spec.name)then new('Frame',{Size=UDim2.fromOffset(5,5),BackgroundColor3=C.accent,LayoutOrder=3,Parent=
b},{corner(3)})end return b end function Rows.player(parent,item,selected,order)local b=base(parent,order,44,selected)
local p=item.player local av=Controls.avatar(b,p.UserId,28)av.AnchorPoint=Vector2.new(0,0.5)av.Position=UDim2.fromScale(
0,0.5)Create.text({text=Create.marked(item.label,item.marks),size=13,font=F.medium},{Position=UDim2.fromOffset(38,5),
Size=UDim2.new(1,-110,0,18),Parent=b})Create.text({text=Create.marked(item.sub or'',item.subMarks),size=10.5,font=F.mono
,color=C.text3},{Position=UDim2.fromOffset(38,23),Size=UDim2.new(1,-110,0,14),Parent=b})Create.text({text=item.tag or'',
size=10,color=C.text3,x=Enum.TextXAlignment.Right},{AnchorPoint=Vector2.new(1,0.5),Position=UDim2.fromScale(1,0.5),Size=
UDim2.fromOffset(70,16),Parent=b})return b end function Rows.value(parent,item,selected,order)local b=base(parent,order,
34,selected)Create.text({text=Create.marked(item.label,item.marks),size=13},{Size=UDim2.fromScale(1,1),Parent=b})return
b end function Rows.control(spec,parent,deps,jan,height,scroll)local reg=deps.registry local name=spec.name local a1=
spec.args and spec.args[1]if spec.kind=='value'and a1 and a1.kind=='number'then local lo,hi=a1.min or 0,a1.max or 100
local bar=FillBar.new(parent,{height=height,min=lo,max=hi,step=a1.step or 1,default=spec.default,scroll=scroll,jan=jan,
title=function()return deps.t('c.'..name)end,format=function(v)return Format.value(v)end,value=function()return
tonumber(reg:Value(name))or spec.default or lo end,active=function()return reg:IsActive(name)end,enabled=function()
return not reg:IsDisabled(name)and reg:Missing(spec)==nil end,commit=function(v)deps.run(name..' '..Format.value(v))end}
)return{kind='bar',refresh=bar.refresh,bar=bar}elseif spec.kind=='toggle'then local sw=Controls.switch(parent)sw.set(reg
:IsActive(name))return{kind='switch',refresh=function()sw.set(reg:IsActive(name))end}end Controls.glyph(if Format.
requiredArg(spec)then'chevron-down'else'arrow-right',parent,14,C.text3)return{kind='arrow',refresh=function()end}end
return Rows end function __DARKLUA_BUNDLE_MODULES.v()local v=__DARKLUA_BUNDLE_MODULES.cache.v if not v then v={c=
__modImpl()}__DARKLUA_BUNDLE_MODULES.cache.v=v end return v.c end end do local function __modImpl()local I18n=
__DARKLUA_BUNDLE_MODULES.d()local Log=__DARKLUA_BUNDLE_MODULES.e()local Rows=__DARKLUA_BUNDLE_MODULES.v()local Types=
__DARKLUA_BUNDLE_MODULES.c()return nil end function __DARKLUA_BUNDLE_MODULES.w()local v=__DARKLUA_BUNDLE_MODULES.cache.w
if not v then v={c=__modImpl()}__DARKLUA_BUNDLE_MODULES.cache.w=v end return v.c end end do local function __modImpl()
local UserInputService=game:GetService('UserInputService')local Janitor=__DARKLUA_BUNDLE_MODULES.j()local SLOP=6 local
MARGIN=6 local Drag={}local function viewport()local cam=workspace.CurrentCamera return if cam then cam.ViewportSize
else Vector2.new(1280,720)end Drag.viewport=viewport function Drag.place(target,x,y)local vp=viewport()local w,h=target.
AbsoluteSize.X,target.AbsoluteSize.Y target.Position=UDim2.fromOffset(math.clamp(x,MARGIN,math.max(MARGIN,vp.X-w-MARGIN)
),math.clamp(y,MARGIN,math.max(MARGIN,vp.Y-h-MARGIN)))end function Drag.attach(handle,target,jan,onEnd)local start=nil
local origin=Vector2.zero local moved=false jan:Connect(handle.InputBegan,function(io)local t=io.UserInputType if t==
Enum.UserInputType.MouseButton1 or t==Enum.UserInputType.Touch then start=io.Position origin=Vector2.new(target.Position
.X.Offset,target.Position.Y.Offset)moved=false end end)jan:Connect(UserInputService.InputChanged,function(io)local s=
start if not s then return end local t=io.UserInputType if t~=Enum.UserInputType.MouseMovement and t~=Enum.UserInputType
.Touch then return end local d=io.Position-s if moved or math.abs(d.X)+math.abs(d.Y)>SLOP then moved=true Drag.place(
target,origin.X+d.X,origin.Y+d.Y)end end)jan:Connect(UserInputService.InputEnded,function(io)local t=io.UserInputType if
start and(t==Enum.UserInputType.MouseButton1 or t==Enum.UserInputType.Touch)then start=nil if moved then onEnd(target.
Position.X.Offset,target.Position.Y.Offset)task.defer(function()moved=false end)end end end)return{moved=function()
return moved end,clamp=function()Drag.place(target,target.Position.X.Offset,target.Position.Y.Offset)end}end return Drag
end function __DARKLUA_BUNDLE_MODULES.x()local v=__DARKLUA_BUNDLE_MODULES.cache.x if not v then v={c=__modImpl()}
__DARKLUA_BUNDLE_MODULES.cache.x=v end return v.c end end do local function __modImpl()local Players=game:GetService(
'Players')local Common=__DARKLUA_BUNDLE_MODULES.w()local Controls=__DARKLUA_BUNDLE_MODULES.t()local Create=
__DARKLUA_BUNDLE_MODULES.s()local Drag=__DARKLUA_BUNDLE_MODULES.x()local Janitor=__DARKLUA_BUNDLE_MODULES.j()local
Signal=__DARKLUA_BUNDLE_MODULES.b()local Theme=__DARKLUA_BUNDLE_MODULES.r()local C,F,LINE,S=Theme.C,Theme.F,Theme.LINE,
Theme.SIZE local new,corner,pad,list=Create.new,Create.corner,Create.pad,Create.list local ON_BG=Color3.fromHex('2a1416'
)local ON_TEXT=Color3.fromHex('ff8a93')local LONG_PRESS=0.45 local SORTS={'best','fav','new'}local TABS={'look',
'catalog','emotes'}local AvatarPanel={}local function quote(s)return'"'..string.gsub(s,'"','')..'"'end local function 
onSecondary(jan,b,fn)local pressAt,fired=0,false jan:Connect(b.MouseButton2Click,fn)jan:Connect(b.InputBegan,function(io
)if io.UserInputType==Enum.UserInputType.Touch then pressAt=os.clock()fired=false local stamp=pressAt task.delay(
LONG_PRESS,function()if pressAt==stamp and b.Parent then fired=true fn()end end)end end)jan:Connect(b.InputEnded,
function(io)if io.UserInputType==Enum.UserInputType.Touch then pressAt=0 end end)return function()if fired then fired=
false return true end return false end end local function figure(parent,w,h)local box=new('Frame',{Name='Figure',
BackgroundTransparency=1,AnchorPoint=Vector2.new(0.5,0.5),Position=UDim2.fromScale(0.5,0.5),Size=UDim2.fromOffset(w,h),
Parent=parent})local col=Color3.fromHex('3a3a3a')for _,p in{{0.38,0,0.24,0.19},{0.3,0.21,0.4,0.34},{0.14,0.21,0.14,0.32}
,{0.72,0.21,0.14,0.32},{0.31,0.57,0.18,0.4},{0.51,0.57,0.18,0.4}}do new('Frame',{BackgroundColor3=col,BorderSizePixel=0,
Position=UDim2.fromScale(p[1],p[2]),Size=UDim2.fromScale(p[3],p[4]),Parent=box},{corner(3)})end return box end local 
function flow(parent,order,gap)local f=new('Frame',{Name='Flow',BackgroundTransparency=1,Size=UDim2.fromScale(1,0),
AutomaticSize=Enum.AutomaticSize.Y,LayoutOrder=order,Parent=parent})new('UIListLayout',{FillDirection=Enum.FillDirection
.Horizontal,Wraps=true,Padding=UDim.new(0,gap),SortOrder=Enum.SortOrder.LayoutOrder,Parent=f})return f end local 
function row(parent,order,h)return new('Frame',{BackgroundTransparency=1,Size=UDim2.new(1,0,0,h),LayoutOrder=order,
Parent=parent},{list('x',8)})end local function flex(parent,order)local sp=new('Frame',{BackgroundTransparency=1,Size=
UDim2.fromScale(0,1),LayoutOrder=order,Parent=parent})pcall(function()new('UIFlexItem',{FlexMode=Enum.UIFlexMode.Fill,
Parent=sp})end)end local function field(parent,placeholder,w,order)local f=new('Frame',{Name='Field',BackgroundColor3=C.
raised,Size=w,LayoutOrder=order,Parent=parent},{corner(S.radius),pad(10,8)})local box=new('TextBox',{Name='Input',
BackgroundTransparency=1,Size=UDim2.fromScale(1,1),Text='',PlaceholderText=placeholder,PlaceholderColor3=C.text3,
TextColor3=C.text1,TextSize=12.5,FontFace=F.regular,TextXAlignment=Enum.TextXAlignment.Left,ClearTextOnFocus=false,
AutoLocalize=false,Parent=f})return f,box end function AvatarPanel.new(layer,jan,deps)local touch=Theme.touch local t,
store,reg=deps.t,deps.store,deps.registry local api=(reg:Api('avatar'))local W=if touch then S.panelTouch else 760 local
NAV=if touch then 0 else 222 local BODY_H=404 local frame=new('Frame',{Name='Avatar',Size=UDim2.fromOffset(W,0),
AutomaticSize=Enum.AutomaticSize.Y,BackgroundColor3=C.surface,Visible=false,Active=true,Parent=layer},{corner(if touch
then S.card else S.window),Create.stroke(LINE.strong),list('y',0)})Create.shadow(frame,Theme.SHADOW.window)local tab=
'look'local isOpen=false local pageJan=Janitor.new()jan:Add(pageJan)local previewJan=Janitor.new()jan:Add(previewJan)
local function state()return api.State()end local header=new('Frame',{Name='Header',BackgroundTransparency=1,Size=UDim2.
new(1,0,0,if touch then 50 else 52),LayoutOrder=1,Active=true,Parent=frame},{pad(if touch then 12 else 16,12),list('x',9
)})Controls.logo(header,15).LayoutOrder=1 Create.text({text=t('avu.title'),size=if touch then 15 else 14,font=F.semibold
,auto=true},{LayoutOrder=2,Parent=header})local badge=new('Frame',{Name='Badge',BackgroundColor3=C.white,
BackgroundTransparency=0.94,AutomaticSize=Enum.AutomaticSize.X,Size=UDim2.fromOffset(0,20),LayoutOrder=3,Parent=header},
{corner(6),pad(7,8),list('x',5)})Controls.glyph('eye',badge,11,C.text2).LayoutOrder=1 Create.text({text=t('avu.only_you'
),size=10,font=F.medium,color=C.text2,auto=true},{LayoutOrder=2,Parent=badge})flex(header,4)local searchFrame,searchBox=
field(header,t('avu.search'),UDim2.fromOffset(if touch then 150 else 250,if touch then 36 else 30),5)searchFrame.Name=
'Search'local close=Controls.iconButton(header,'x')close.LayoutOrder=6 Controls.hairline(frame,2)local body=new('Frame',
{Name='Body',BackgroundTransparency=1,Size=if touch then UDim2.fromScale(1,0)else UDim2.new(1,0,0,BODY_H),AutomaticSize=
if touch then Enum.AutomaticSize.Y else Enum.AutomaticSize.None,LayoutOrder=3,Parent=frame})local viewport=nil local
previewName=nil local previewMeta=nil if not touch then local left=new('Frame',{Name='Preview',BackgroundTransparency=1,
Size=UDim2.new(0,NAV,1,0),Parent=body},{pad(16,16,16,16),list('y',10)})local card=new('Frame',{Name='Card',
BackgroundColor3=C.track,Size=UDim2.new(1,0,0,262),ClipsDescendants=true,LayoutOrder=1,Parent=left},{corner(S.card),
Create.stroke(LINE.subtle)})local vf=new('ViewportFrame',{Name='Viewport',BackgroundTransparency=1,Size=UDim2.new(1,0,1,
-34),Ambient=Color3.fromRGB(150,150,150),LightColor=Color3.new(1,1,1),LightDirection=Vector3.new(-0.6,-1,-0.8),Parent=
card})viewport=vf local cap=new('Frame',{BackgroundTransparency=1,Position=UDim2.new(0,0,1,-34),Size=UDim2.new(1,0,0,34)
,Parent=card},{pad(12,12)})previewName=Create.text({text='',size=13,font=F.medium},{Size=UDim2.new(1,-34,1,0),Parent=cap
})Create.text({text='R15',size=10,font=F.mono,color=C.text3,x=Enum.TextXAlignment.Right},{Name='Rig',AnchorPoint=Vector2
.new(1,0),Position=UDim2.fromScale(1,0),Size=UDim2.new(0,30,1,0),Parent=cap})previewMeta=Create.text({text='',size=10,
font=F.mono,color=C.text3,x=Enum.TextXAlignment.Center},{Size=UDim2.new(1,0,0,14),LayoutOrder=2,Parent=left})local reset
=Controls.button(left,t('avu.reset'),'plain','refresh')reset.Name='Reset'reset.AutomaticSize=Enum.AutomaticSize.None
reset.Size=UDim2.new(1,0,0,36)reset.LayoutOrder=3 local rl=reset:FindFirstChildOfClass('UIListLayout')if rl then rl.
HorizontalAlignment=Enum.HorizontalAlignment.Center end jan:Connect(reset.Activated,function()task.spawn(api.Reset)end)
new('Frame',{BackgroundColor3=C.white,BackgroundTransparency=LINE.default,BorderSizePixel=0,Position=UDim2.fromOffset(
NAV,0),Size=UDim2.new(0,1,1,0),Parent=body})end local right=new('Frame',{Name='Content',BackgroundTransparency=1,
Position=UDim2.fromOffset(if touch then 0 else NAV+1,0),Size=if touch then UDim2.fromScale(1,0)else UDim2.new(1,-NAV-1,1
,0),AutomaticSize=if touch then Enum.AutomaticSize.Y else Enum.AutomaticSize.None,Parent=body},{pad(if touch then 12
else 16,if touch then 12 else 16,if touch then 8 else 14,if touch then 4 else 0),list('y',10)})local CONTENT_W=W-(if
touch then 24 else NAV+1+32)-6 local tabsBar=new('Frame',{Name='Tabs',BackgroundColor3=C.track,AutomaticSize=if touch
then Enum.AutomaticSize.None else Enum.AutomaticSize.X,Size=if touch then UDim2.new(1,0,0,38)else UDim2.fromOffset(0,34)
,LayoutOrder=1,Parent=right},{corner(S.radius),pad(3,3,3,3),list('x',2)})local tabButtons={}for i,id in TABS do local b=
new('TextButton',{Name='Tab/'..id,Text=t('avu.tab_'..id),AutoButtonColor=false,BackgroundColor3=C.control,
BackgroundTransparency=1,AutomaticSize=if touch then Enum.AutomaticSize.None else Enum.AutomaticSize.X,Size=if touch
then UDim2.new(1/#TABS,-2,1,0)else UDim2.fromScale(0,1),TextSize=13,FontFace=F.medium,TextColor3=C.text2,AutoLocalize=
false,LayoutOrder=i,Parent=tabsBar},{corner(6),pad(10,10)})tabButtons[id]=b end local page=new('ScrollingFrame',{Name=
'Page',BackgroundTransparency=1,BorderSizePixel=0,Size=if touch then UDim2.fromScale(1,0)else UDim2.new(1,0,1,-44),
CanvasSize=UDim2.fromScale(0,0),AutomaticCanvasSize=Enum.AutomaticSize.Y,ScrollingDirection=Enum.ScrollingDirection.Y,
ScrollBarThickness=3,ScrollBarImageColor3=C.text3,LayoutOrder=2,Parent=right},{pad(0,6,0,12),list('y',10)})if touch then
Create.fitScroll(page,function()return 150 end)end Controls.hairline(frame,4)local foot=new('Frame',{Name='Status',
BackgroundTransparency=1,Size=UDim2.new(1,0,0,if touch then 54 else 52),LayoutOrder=5,Parent=frame},{pad(if touch then
12 else 16,14),list('x',10)})local dot=new('Frame',{Size=UDim2.fromOffset(8,8),BackgroundColor3=C.text3,LayoutOrder=1,
Parent=foot},{corner(4)})local statusText=Create.text({text='',size=13,font=F.medium,auto=true},{Name='Text',LayoutOrder
=2,Parent=foot})local hintText=Create.text({text='',size=10.5,font=F.mono,color=C.text3,auto=true},{LayoutOrder=3,Parent
=foot})hintText.Visible=not touch flex(foot,4)local leftBtn=if touch then Controls.button(foot,t('avu.reset'),'plain')
else Controls.button(foot,t('avu.export'),'ghost','arrow-right')leftBtn.LayoutOrder=5 local saveBtn=Controls.button(foot
,if touch then t('avu.save_short')else t('avu.save'),'accent',if touch then nil else'check')saveBtn.Name='Save'saveBtn.
LayoutOrder=6 jan:Connect(leftBtn.Activated,function()if touch then task.spawn(api.Reset)else deps.run('exportoutfit')
end end)jan:Connect(saveBtn.Activated,function()deps.run('saveoutfit')end)local function sourceText(s)if not s.owner
then return t('avu.status_mine')end return t('avu.status_worn',s.label or'?')..(if s.source then' \u{b7} '..t('avu.src_'
..s.source)else'')end local function renderStatus()local s=state()dot.BackgroundColor3=if s.owner then C.ok else C.text3
statusText.Text=Create.marked(sourceText(s),nil)hintText.Text=if s.owner then t('avu.hint_unwear')else t('avu.hint_wear'
)if previewName then previewName.Text=Create.marked(s.label or Players.LocalPlayer.DisplayName,nil)end if previewMeta
then previewMeta.Text=if s.owner then t('avu.src_'..(s.source or'outfit'))else'@'..Players.LocalPlayer.Name end end
local function renderPreview()if not viewport then return end local vf=viewport previewJan:Cleanup()for _,c in vf:
GetChildren()do c:Destroy()end local model=api.Preview()if not model then return end local world=Instance.new(
'WorldModel')world.Parent=vf previewJan:Add(world)model:PivotTo(CFrame.new())model.Parent=world local cf,size=model:
GetBoundingBox()local cam=Instance.new('Camera')cam.FieldOfView=30 local dist=(size.Y/2)/math.tan(math.rad(15))*1.12
local yaw=0 local function place()local rot=CFrame.Angles(0,yaw,0)cam.CFrame=CFrame.lookAt(cf.Position+rot:
VectorToWorldSpace(Vector3.new(0,size.Y*0.04,-dist)),cf.Position)end place()cam.Parent=vf vf.CurrentCamera=cam local
dragging=nil previewJan:Connect(vf.InputBegan,function(io)if io.UserInputType==Enum.UserInputType.MouseButton1 or io.
UserInputType==Enum.UserInputType.Touch then dragging=io.Position end end)previewJan:Connect(vf.InputChanged,function(io
)local d=dragging if d and(io.UserInputType==Enum.UserInputType.MouseMovement or io.UserInputType==Enum.UserInputType.
Touch)then yaw-=(io.Position.X-d.X)*0.012 dragging=io.Position place()end end)previewJan:Connect(vf.InputEnded,function(
io)if io.UserInputType==Enum.UserInputType.MouseButton1 or io.UserInputType==Enum.UserInputType.Touch then dragging=nil
end end)end local expanded=false local sort=1 local catalogKind='bodies'local query=''local results={}local pager=nil
local searching=false local searchToken=0 local renderPage local function clearPage()pageJan:Cleanup()for _,c in page:
GetChildren()do if c:IsA('GuiObject')then c:Destroy()end end end local function eyebrowRow(order,text)local r=row(page,
order,22)Controls.eyebrow(r,text).LayoutOrder=1 flex(r,2)return r end local function note(order,text)Create.text({text=
text,size=12.5,color=C.text3},{Size=UDim2.new(1,0,0,28),LayoutOrder=order,Parent=page})end local function lookPage()
local s=state()local others={}for _,p in Players:GetPlayers()do if p~=Players.LocalPlayer then table.insert(others,p)end
end table.sort(others,function(a,b)return string.lower(a.DisplayName)<string.lower(b.DisplayName)end)local head=
eyebrowRow(1,t('avu.server',#others))if not touch then Create.text({text=t('avu.server_hint'),size=10.5,color=C.text3,
auto=true},{LayoutOrder=3,Parent=head})end local function worn(p)return s.owner=='wear'and s.source=='server'and s.label
==p.Name end if#others==0 then note(2,t('avu.alone'))elseif touch then local strip=new('ScrollingFrame',{Name='Players',
BackgroundTransparency=1,BorderSizePixel=0,Size=UDim2.new(1,0,0,68),CanvasSize=UDim2.fromScale(0,0),AutomaticCanvasSize=
Enum.AutomaticSize.X,ScrollingDirection=Enum.ScrollingDirection.X,ScrollBarThickness=0,LayoutOrder=2,Parent=page},{list(
'x',8,Enum.VerticalAlignment.Top)})for i,p in others do local on=worn(p)local b=new('TextButton',{Name='Player/'..p.Name
,Text='',AutoButtonColor=false,BackgroundTransparency=1,Size=UDim2.fromOffset(62,66),LayoutOrder=i,Parent=strip})local
av=Controls.avatar(b,p.UserId,44)av.AnchorPoint=Vector2.new(0.5,0)av.Position=UDim2.fromScale(0.5,0)if on then Create.
stroke(0,C.accent).Parent=av end Create.text({text=Create.marked(p.DisplayName,nil),size=11,font=if on then F.medium
else F.regular,color=if on then ON_TEXT else C.text2,x=Enum.TextXAlignment.Center},{Position=UDim2.fromOffset(0,49),Size
=UDim2.new(1,0,0,16),Parent=b})pageJan:Connect(b.Activated,function()deps.run('wear '..p.Name)end)end else local grid=
flow(page,2,6)grid.Name='Players'local shown=if expanded or#others<=6 then#others else 5 local tileW=math.floor((
CONTENT_W-12)/3)for i=1,shown do local p=others[i]local on=worn(p)local b=new('TextButton',{Name='Player/'..p.Name,Text=
'',AutoButtonColor=false,BackgroundColor3=if on then ON_BG else C.track,Size=UDim2.fromOffset(tileW,44),LayoutOrder=i,
Parent=grid},{corner(S.radius),pad(6,10),list('x',9)})Controls.avatar(b,p.UserId,32).LayoutOrder=1 local col=new('Frame'
,{BackgroundTransparency=1,Size=UDim2.new(1,-54,1,0),LayoutOrder=2,Parent=b},{list('y',0,Enum.VerticalAlignment.Center)}
)Create.text({text=Create.marked(p.DisplayName,nil),size=13,font=F.medium},{Size=UDim2.new(1,0,0,17),Parent=col})Create.
text({text='@'..p.Name,size=10.5,font=F.mono,color=C.text3},{Size=UDim2.new(1,0,0,13),LayoutOrder=2,Parent=col})if on
then new('Frame',{Size=UDim2.fromOffset(6,6),BackgroundColor3=C.accent,LayoutOrder=3,Parent=b},{corner(3)})end pageJan:
Connect(b.Activated,function()deps.run('wear '..p.Name)end)end if shown<#others then local more=new('TextButton',{Name=
'More',Text=t('avu.more',#others-shown),AutoButtonColor=false,BackgroundTransparency=1,Size=UDim2.fromOffset(tileW,44),
TextSize=12.5,FontFace=F.medium,TextColor3=C.text2,AutoLocalize=false,LayoutOrder=99,Parent=grid},{corner(S.radius),
Create.stroke(LINE.default)})pageJan:Connect(more.Activated,function()expanded=true renderPage()end)end end local
outfits=api.Outfits()local oh=eyebrowRow(3,t('avu.outfits',#outfits))local saveCur=new('TextButton',{Name='SaveCurrent',
Text='',AutoButtonColor=false,BackgroundTransparency=1,AutomaticSize=Enum.AutomaticSize.X,Size=UDim2.fromScale(0,1),
LayoutOrder=3,Parent=oh},{list('x',5)})Controls.glyph('plus',saveCur,12,C.text2).LayoutOrder=1 Create.text({text=t(
'avu.save_current'),size=12.5,font=F.medium,color=C.text2,auto=true},{LayoutOrder=2,Parent=saveCur})pageJan:Connect(
saveCur.Activated,function()deps.run('saveoutfit')end)local entries={{name=t('avu.mine'),meta=t('avu.meta_mine'),
selected=s.owner==nil,saved=false,wear=function()task.spawn(api.Reset)end}}if s.owner and s.owner~='outfit'then table.
insert(entries,{name=s.label or'?',meta=t('avu.meta_worn'),selected=true,saved=false,wear=function()end})end for _,name
in outfits do table.insert(entries,{name=name,meta=t('avu.meta_saved'),selected=s.owner=='outfit'and s.label==name,saved
=true,wear=function()deps.run('outfit '..quote(name))end})end local grid=flow(page,4,if touch then 6 else 8)grid.Name=
'Outfits'for i,e in entries do local b if touch then b=new('TextButton',{Name='Outfit/'..e.name,Text='',AutoButtonColor=
false,BackgroundColor3=if e.selected then ON_BG else C.control,AutomaticSize=Enum.AutomaticSize.X,Size=UDim2.fromOffset(
0,38),LayoutOrder=i,Parent=grid},{corner(S.radius),pad(12,12),list('x',6)})if e.selected then new('Frame',{Size=UDim2.
fromOffset(6,6),BackgroundColor3=C.accent,LayoutOrder=1,Parent=b},{corner(3)})end Create.text({text=Create.marked(e.name
,nil),size=13,font=F.medium,auto=true},{LayoutOrder=2,Parent=b})else b=new('TextButton',{Name='Outfit/'..e.name,Text='',
AutoButtonColor=false,BackgroundTransparency=1,Size=UDim2.fromOffset(104,120),LayoutOrder=i,Parent=grid},{corner(S.
radius),pad(4,4,4,6),list('y',4)})Create.stroke(if e.selected then 0 else LINE.subtle,if e.selected then C.accent else
nil).Parent=b local thumb=new('Frame',{BackgroundColor3=C.control,Size=UDim2.new(1,0,0,66),LayoutOrder=1,Parent=b},{
corner(6)})figure(thumb,30,44)local txtCol=new('Frame',{BackgroundTransparency=1,Size=UDim2.new(1,0,0,36),LayoutOrder=2,
Parent=b},{pad(4,4),list('y',1)})Create.text({text=Create.marked(e.name,nil),size=13,font=F.medium},{Size=UDim2.new(1,0,
0,17),Parent=txtCol})Create.text({text='<uc>'..Create.marked(e.meta,nil)..'</uc>',size=9.5,font=F.mono,color=C.text3},{
Size=UDim2.new(1,0,0,13),LayoutOrder=2,Parent=txtCol})end local suppressed=onSecondary(pageJan,b,function()if e.saved
then deps.openBar('deloutfit '..quote(e.name))end end)pageJan:Connect(b.Activated,function()if not suppressed()then e.
wear()end end)end local rules=new('TextButton',{Name='Rules',Text='',AutoButtonColor=false,BackgroundColor3=C.track,Size
=UDim2.new(1,0,0,if touch then 44 else 50),LayoutOrder=5,Parent=page},{corner(S.radius),pad(12,12)})local rc=new('Frame'
,{BackgroundTransparency=1,Size=UDim2.new(1,-44,1,0),Parent=rules},{list('y',2,Enum.VerticalAlignment.Center)})Create.
text({text=t('avu.rules'),size=13,font=F.medium},{Size=UDim2.new(1,0,0,17),Parent=rc})if not touch then Create.text({
text=t('avu.rules_sub'),size=11,color=C.text3},{Size=UDim2.new(1,0,0,14),LayoutOrder=2,Parent=rc})end local sw=Controls.
switch(rules)sw.frame.AnchorPoint=Vector2.new(1,0.5)sw.frame.Position=UDim2.fromScale(1,0.5)sw.set(reg:IsActive(
'avatarrules'))pageJan:Connect(rules.Activated,function()deps.run('avatarrules')end)end local function catalogPage()
local r=row(page,1,32)local f,box=field(r,t('avu.catalog_search'),UDim2.new(1,-150,1,0),1)f.Name='CatalogSearch'box.Text
=query local sortBtn=new('TextButton',{Name='Sort',Text='',AutoButtonColor=false,BackgroundColor3=C.track,Size=UDim2.
new(0,142,1,0),LayoutOrder=2,Parent=r},{corner(S.radius),pad(10,10),list('x',6)})Create.text({text=t('avu.sort_'..SORTS[
sort]),size=12.5,font=F.medium,color=C.text2,auto=true},{LayoutOrder=1,Parent=sortBtn})Controls.glyph('chevron-down',
sortBtn,12,C.text3).LayoutOrder=2 local chips=row(page,2,if touch then 34 else 30)for i,kind in{'bodies','mine'}do local
on=catalogKind==kind local c=new('TextButton',{Name='Kind/'..kind,Text='',AutoButtonColor=false,BackgroundColor3=if on
then ON_BG else C.track,AutomaticSize=Enum.AutomaticSize.X,Size=UDim2.fromScale(0,1),LayoutOrder=i,Parent=chips},{
corner(S.radius),pad(12,12),list('x',6)})Create.text({text=t('avu.kind_'..kind),size=12.5,font=F.medium,auto=true},{
LayoutOrder=1,Parent=c})pageJan:Connect(c.Activated,function()catalogKind=kind renderPage()end)end local cols=3 local
cellW=math.floor((CONTENT_W-(cols-1)*8)/cols)local thumbH=if touch then 76 else 100 local grid=flow(page,3,8)grid.Name=
'Results'local s=state()local function cell(i,name,meta,image,selected,onTap,onSecondaryTap)local b=new('TextButton',{
Name='Cell/'..name,Text='',AutoButtonColor=false,BackgroundTransparency=1,Size=UDim2.fromOffset(cellW,thumbH+42),
LayoutOrder=i,Parent=grid},{list('y',4)})local thumb=new('Frame',{Name='Thumb',BackgroundColor3=C.raised,Size=UDim2.new(
1,0,0,thumbH),LayoutOrder=1,ClipsDescendants=true,Parent=b},{corner(S.radius)})if selected then Create.stroke(0,C.accent
).Parent=thumb end if image then new('ImageLabel',{BackgroundTransparency=1,Size=UDim2.fromScale(1,1),Image=image,
ScaleType=Enum.ScaleType.Fit,Parent=thumb})else figure(thumb,40,58)end Create.text({text=Create.marked(name,nil),size=
12.5,font=F.medium},{Size=UDim2.new(1,0,0,16),LayoutOrder=2,Parent=b})Create.text({text=meta,size=10,font=F.mono,color=C
.text3},{Size=UDim2.new(1,0,0,13),LayoutOrder=3,Parent=b})local suppressed=onSecondary(pageJan,b,function()if
onSecondaryTap then onSecondaryTap()end end)pageJan:Connect(b.Activated,function()if not suppressed()then onTap()end end
)end if catalogKind=='mine'then local outfits=api.Outfits()for i,name in outfits do cell(i,name,t('avu.meta_saved'),nil,
s.owner=='outfit'and s.label==name,function()deps.run('outfit '..quote(name))end)end if#outfits==0 then note(4,t(
'av.outfits_none'))end else for i,it in results do cell(i,it.name,t('avu.body'),string.format(
'rbxthumb://type=BundleThumbnail&id=%d&w=150&h=150',it.id),s.owner=='bundle'and s.label==it.name,function()deps.run(
'bundle '..it.id)end,function()task.spawn(function()deps.run('bundle '..it.id)task.wait(1.5)deps.run('saveoutfit '..it.
name)end)end)end if searching then note(4,t('avu.searching'))elseif#results==0 then note(4,t('ui.nothing'))elseif pager
and not(pager).finished()then local more=Controls.button(page,t('avu.load_more'),'plain')more.LayoutOrder=5 pageJan:
Connect(more.Activated,function()local p=pager searching=true renderPage()task.spawn(function()local got=p.next()for _,
it in got do table.insert(results,it)end searching=false if isOpen and tab=='catalog'then renderPage()end end)end)end
end local function run()searchToken+=1 local my=searchToken searching=true results={}pager=nil renderPage()task.spawn(
function()local got=api.Search(query,SORTS[sort])if my~=searchToken then return end searching=false pager=got results=if
got then table.clone(got.items)else{}if isOpen and tab=='catalog'then renderPage()end end)end pageJan:Connect(box.
FocusLost,function(enter)if enter then query=box.Text catalogKind='bodies'run()end end)pageJan:Connect(sortBtn.Activated
,function()sort=sort%#SORTS+1 run()end)if catalogKind=='bodies'and not searching and not pager and#results==0 and
searchToken==0 then task.defer(run)end end local function emotesPage()local wheel=api.Wheel()local head=eyebrowRow(1,t(
'avu.wheel',#wheel))local f,box=field(head,t('avu.emote_id'),UDim2.fromOffset(if touch then 130 else 160,30),3)f.Name=
'EmoteId'local add=Controls.iconButton(head,'plus',30,true)add.LayoutOrder=4 local function addIt()local id=string.
match(box.Text,'(%d+)')if id then deps.run('addemote '..id)box.Text=''end end pageJan:Connect(add.Activated,addIt)
pageJan:Connect(box.FocusLost,function(enter)if enter then addIt()end end)local cols=4 local tileW=math.floor((CONTENT_W
-(cols-1)*6)/cols)local grid=flow(page,2,6)grid.Name='Emotes'for i,e in wheel do local b=new('TextButton',{Name='Emote/'
..e.id,Text='',AutoButtonColor=false,BackgroundColor3=C.track,Size=UDim2.fromOffset(tileW,if touch then 70 else 80),
LayoutOrder=i,Parent=grid},{corner(S.radius),pad(10,10,8,8),list('y',4)})local top=new('Frame',{BackgroundTransparency=1
,Size=UDim2.new(1,0,0,14),LayoutOrder=1,Parent=b},{list('x',4)})Create.text({text=tostring(i),size=10,font=F.mono,color=
C.text3,auto=true},{LayoutOrder=1,Parent=top})flex(top,2)if e.fromOutfit then Create.text({text=t('avu.tag_outfit'),size
=10,color=C.text3,auto=true},{LayoutOrder=3,Parent=top})end new('ImageLabel',{Name='Icon',BackgroundTransparency=1,Size=
UDim2.fromOffset(if touch then 22 else 26,if touch then 22 else 26),Image=string.format(
'rbxthumb://type=Asset&id=%d&w=150&h=150',e.id),LayoutOrder=2,Parent=b})Create.text({text=Create.marked(e.name,nil),size
=12.5,font=F.medium},{Size=UDim2.new(1,0,0,16),LayoutOrder=3,Parent=b})local suppressed=onSecondary(pageJan,b,function()
if not e.fromOutfit then deps.run('delemote '..e.id)end end)pageJan:Connect(b.Activated,function()if not suppressed()
then deps.run('emote '..e.id)end end)end if#wheel==0 then note(3,t('avu.wheel_empty'))end local function option(order,
title,sub,key,on,toggle)local o=new('TextButton',{Name='Option',Text='',AutoButtonColor=false,BackgroundColor3=C.track,
Size=UDim2.new(1,0,0,if touch then 44 else 50),LayoutOrder=order,Parent=page},{corner(S.radius),pad(12,12)})local col=
new('Frame',{BackgroundTransparency=1,Size=UDim2.new(1,-44,1,0),Parent=o},{list('y',2,Enum.VerticalAlignment.Center)})
Create.text({text=title,size=13,font=F.medium},{Size=UDim2.new(1,0,0,17),Parent=col})if not touch then local subRow=new(
'Frame',{BackgroundTransparency=1,Size=UDim2.new(1,0,0,16),LayoutOrder=2,Parent=col},{list('x',6)})Create.text({text=sub
,size=11,color=C.text3,auto=true},{LayoutOrder=1,Parent=subRow})if key then Controls.kbd(subRow,key).LayoutOrder=2 end
end local sw=Controls.switch(o)sw.frame.AnchorPoint=Vector2.new(1,0.5)sw.frame.Position=UDim2.fromScale(1,0.5)sw.set(on)
pageJan:Connect(o.Activated,toggle)end option(4,t('avu.outfit_first'),t('avu.outfit_first_sub'),nil,api.OutfitEmotes(),
function()api.SetOutfitEmotes(not api.OutfitEmotes())end)option(5,t('avu.own_wheel'),t('avu.own_wheel_sub'),'.',store.
data.emoteWheel,function()store.data.emoteWheel=not store.data.emoteWheel store:Save('emoteWheel')renderPage()end)end
renderPage=function()clearPage()for id,b in tabButtons do local on=id==tab b.BackgroundTransparency=if on then 0 else 1
b.TextColor3=if on then C.text1 else C.text2 end if tab=='catalog'then catalogPage()elseif tab=='emotes'then emotesPage(
)else lookPage()end renderStatus()end for id,b in tabButtons do jan:Connect(b.Activated,function()tab=id page.
CanvasPosition=Vector2.zero renderPage()end)end jan:Connect(searchBox.FocusLost,function(enter)local text=string.match(
searchBox.Text,'^%s*(.-)%s*$')or''if enter and text~=''then deps.run('wear '..string.gsub(text,'%s+',''))searchBox.Text=
''end end)jan:Connect(close.Activated,function()isOpen=false frame.Visible=false end)local queued=false local function 
soon(withPreview)if not isOpen or queued then return end queued=true task.defer(function()queued=false if isOpen and
frame.Parent then renderPage()if withPreview then renderPreview()end end end)end jan:Add(api.Changed:Connect(function()
soon(true)end))jan:Add(reg.StateChanged:Connect(function(name)if name=='avatarrules'then soon(false)end end))jan:
Connect(Players.PlayerAdded,function()if tab=='look'then soon(false)end end)jan:Connect(Players.PlayerRemoving,function(
)if tab=='look'then soon(false)end end)Drag.attach(header,frame,jan,function(x,y)if not touch then store.data.panels.
avatar={x=x,y=y}store:Save()end end)return{frame=frame,open=function(which)if which and table.find(TABS,which)then tab=
which end isOpen=true frame.Visible=true renderPage()renderPreview()task.defer(function()local vp=Drag.viewport()local
saved=store.data.panels.avatar if touch then Drag.place(frame,(vp.X-W)/2,0)elseif saved then Drag.place(frame,saved.x,
saved.y)else Drag.place(frame,(vp.X-W)/2,96)end end)end,close=function()isOpen=false frame.Visible=false end,isOpen=
function()return isOpen end}end return AvatarPanel end function __DARKLUA_BUNDLE_MODULES.y()local v=
__DARKLUA_BUNDLE_MODULES.cache.y if not v then v={c=__modImpl()}__DARKLUA_BUNDLE_MODULES.cache.y=v end return v.c end
end do local function __modImpl()local Controls=__DARKLUA_BUNDLE_MODULES.t()local Create=__DARKLUA_BUNDLE_MODULES.s()
local Drag=__DARKLUA_BUNDLE_MODULES.x()local Janitor=__DARKLUA_BUNDLE_MODULES.j()local Store=__DARKLUA_BUNDLE_MODULES.l(
)local Theme=__DARKLUA_BUNDLE_MODULES.r()local C,F,LINE,S=Theme.C,Theme.F,Theme.LINE,Theme.SIZE local new,corner,pad,
list=Create.new,Create.corner,Create.pad,Create.list local Panel={}function Panel.new(layer,jan,o)local width=if Theme.
touch then math.min(S.panelTouch,o.width or S.panel+60)else o.width or S.panel local frame=new('Frame',{Name='Panel/'..o
.id,Size=UDim2.fromOffset(width,0),AutomaticSize=Enum.AutomaticSize.Y,BackgroundColor3=C.surface,Visible=false,Active=
true,Parent=layer},{corner(S.card),Create.stroke(LINE.strong),list('y',0)})Create.shadow(frame,Theme.SHADOW.pop)local
header=new('Frame',{Name='Header',BackgroundTransparency=1,Size=UDim2.new(1,0,0,if Theme.touch then 44 else 38),
LayoutOrder=1,Active=true,Parent=frame},{pad(8,8)})local back=Controls.iconButton(header,'arrow-left')back.AnchorPoint=
Vector2.new(0,0.5)back.Position=UDim2.fromScale(0,0.5)back.Visible=false local logo=Controls.logo(header,14)logo.
AnchorPoint=Vector2.new(0,0.5)logo.Position=UDim2.new(0,6,0.5,0)local title=Create.text({text=o.title,size=13,font=F.
medium,x=Enum.TextXAlignment.Center},{Name='Title',AnchorPoint=Vector2.new(0.5,0),Position=UDim2.fromScale(0.5,0),Size=
UDim2.new(1,-80,1,0),Parent=header})local close=Controls.iconButton(header,'x')close.AnchorPoint=Vector2.new(1,0.5)close
.Position=UDim2.fromScale(1,0.5)Controls.hairline(frame,2)local body=new('ScrollingFrame',{Name='Body',
BackgroundTransparency=1,BorderSizePixel=0,Size=UDim2.fromScale(1,0),CanvasSize=UDim2.fromScale(0,0),AutomaticCanvasSize
=Enum.AutomaticSize.Y,ScrollingDirection=Enum.ScrollingDirection.Y,ScrollBarThickness=3,ScrollBarImageColor3=C.text3,
LayoutOrder=3,Parent=frame},{pad(8,8,8,10),list('y',4)})local content=Janitor.new()jan:Add(content)local fitHeight=
Create.fitScroll(body,function()local vp=Drag.viewport()local headerH=header.AbsoluteSize.Y+1 local top=math.max(frame.
Position.Y.Offset,0)return math.max(120,math.min(o.maxHeight or 420,vp.Y-top-headerH-16))end)local function placeInitial
()local vp=Drag.viewport()if Theme.touch then Drag.place(frame,(vp.X-width)/2,8)return end local saved=o.store.data.
panels[o.id]if saved then Drag.place(frame,saved.x,saved.y)else local x,y=o.origin(vp,width)Drag.place(frame,x,y)end end
Drag.attach(header,frame,jan,function(x,y)if not Theme.touch then o.store.data.panels[o.id]={x=x,y=y}o.store:Save()end
end)local isOpen=false local self local function closePanel()if not isOpen then return end isOpen=false frame.Visible=
false if o.onClose then o.onClose()end end jan:Connect(close.Activated,closePanel)local backFn=nil jan:Connect(back.
Activated,function()if backFn then backFn()end end)self={id=o.id,frame=frame,body=body,content=content,setTitle=function
(text)title.Text=text end,setBack=function(fn)backFn=fn back.Visible=fn~=nil logo.Visible=fn==nil end,open=function()
fitHeight()if not isOpen then isOpen=true frame.Visible=true task.defer(function()placeInitial()fitHeight()end)end end,
close=closePanel,isOpen=function()return isOpen end,clear=function()content:Cleanup()for _,c in body:GetChildren()do if
c:IsA('GuiObject')then c:Destroy()end end end}return self end function Panel.row(parent,order,height)return new(
'TextButton',{Name='Row',Text='',AutoButtonColor=false,BackgroundColor3=C.track,Size=UDim2.new(1,0,0,height or(if Theme.
touch then S.rowTouch else 34)),LayoutOrder=order,Parent=parent},{corner(S.radius),pad(10,8),list('x',8)})end function
Panel.spacer(parent,order)local s=new('Frame',{Name='Spacer',BackgroundTransparency=1,Size=UDim2.fromScale(0,1),
LayoutOrder=order,Parent=parent})pcall(function()new('UIFlexItem',{FlexMode=Enum.UIFlexMode.Fill,Parent=s})end)return s
end return Panel end function __DARKLUA_BUNDLE_MODULES.z()local v=__DARKLUA_BUNDLE_MODULES.cache.z if not v then v={c=
__modImpl()}__DARKLUA_BUNDLE_MODULES.cache.z=v end return v.c end end do local function __modImpl()local Common=
__DARKLUA_BUNDLE_MODULES.w()local Controls=__DARKLUA_BUNDLE_MODULES.t()local Create=__DARKLUA_BUNDLE_MODULES.s()local
Panel=__DARKLUA_BUNDLE_MODULES.z()local Rows=__DARKLUA_BUNDLE_MODULES.v()local Theme=__DARKLUA_BUNDLE_MODULES.r()local C
,F,S=Theme.C,Theme.F,Theme.SIZE local new=Create.new local Binds={}function Binds.build(panel,deps,rebuild)panel.clear()
local store,t=deps.store,deps.t local body=panel.body local order=0 local function nextOrder()order+=1 return order end
local keys={}for k in store.data.binds do table.insert(keys,k)end table.sort(keys)if#keys==0 then Create.text({text=t(
'bd.empty'),size=12,color=C.text3},{Size=UDim2.new(1,0,0,26),LayoutOrder=nextOrder(),Parent=body})end for _,key in keys
do local row=Panel.row(body,nextOrder())Controls.kbd(row,key).LayoutOrder=1 Create.text({text=store.data.binds[key],size
=12.5,font=F.mono,auto=true},{LayoutOrder=2,Parent=row})if store.data.holdBinds[key]then Create.text({text=t(
'bd.hold_tag'),size=10,color=C.text3,auto=true},{LayoutOrder=3,Parent=row})end Panel.spacer(row,4)local x=Controls.
iconButton(row,'x',24)x.LayoutOrder=5 panel.content:Connect(x.Activated,function()store.data.binds[key]=nil store.data.
holdBinds[key]=nil store:Save('binds')rebuild()end)end Rows.group(body,t('bd.new'),nextOrder())local state={key=nil,hold
=false}local function field(label)local f=Panel.row(body,nextOrder(),if Theme.touch then S.rowTouch else 36)Create.text(
{text=label,size=12,color=C.text3,auto=true},{LayoutOrder=1,Parent=f})Panel.spacer(f,2)local right=new('Frame',{
BackgroundTransparency=1,AutomaticSize=Enum.AutomaticSize.X,Size=UDim2.fromScale(0,1),LayoutOrder=3,Parent=f},{Create.
list('x',6)})return f,right end local _,cmdRight=field(t('bd.command'))local cmdBox=new('TextBox',{Name='Command',
BackgroundTransparency=1,Size=UDim2.fromOffset(150,24),Text='',PlaceholderText='fly',PlaceholderColor3=C.text3,
TextColor3=C.text1,TextSize=12.5,FontFace=F.mono,TextXAlignment=Enum.TextXAlignment.Right,ClearTextOnFocus=false,
AutoLocalize=false,Parent=cmdRight})local keyRow,keyRight=field(t('bd.key'))local keyText=Create.text({text=t(
'ui.press_key'),size=12.5,font=F.mono,color=C.text2,auto=true},{Parent=keyRight})panel.content:Connect(keyRow.Activated,
function()keyText.Text=t('ui.press_key')keyRow.BackgroundColor3=C.trackHover local stroke=Create.stroke(0)stroke.Color=C
.accent stroke.Parent=keyRow deps.capture(function(k)stroke:Destroy()keyRow.BackgroundColor3=C.track if k==Enum.KeyCode.
Escape then return end state.key=k.Name keyText.Text=k.Name keyText.TextColor3=C.text1 end)end)local modeRow,modeRight=
field(t('bd.mode'))local modeText=Create.text({text=t('bd.press'),size=12.5,font=F.mono,auto=true},{Parent=modeRight})
panel.content:Connect(modeRow.Activated,function()state.hold=not state.hold modeText.Text=if state.hold then t('bd.hold'
)else t('bd.press')end)local add=Controls.button(body,t('bd.add'),'accent','plus')add.AutomaticSize=Enum.AutomaticSize.
None add.Size=UDim2.new(1,0,0,if Theme.touch then 40 else 34)add.LayoutOrder=nextOrder()local l=add:
FindFirstChildOfClass('UIListLayout')if l then l.HorizontalAlignment=Enum.HorizontalAlignment.Center end panel.content:
Connect(add.Activated,function()local line=string.gsub(cmdBox.Text,'^%s*(.-)%s*$','%1')local key=state.key if line==''or
not key then deps.toast('error',t('bd.need'))return end store.data.binds[key]=line store.data.holdBinds[key]=if state.
hold then true else nil store:Save('binds')rebuild()end)end return Binds end function __DARKLUA_BUNDLE_MODULES.A()local
v=__DARKLUA_BUNDLE_MODULES.cache.A if not v then v={c=__modImpl()}__DARKLUA_BUNDLE_MODULES.cache.A=v end return v.c end
end do local function __modImpl()local Common=__DARKLUA_BUNDLE_MODULES.w()local Controls=__DARKLUA_BUNDLE_MODULES.t()
local Create=__DARKLUA_BUNDLE_MODULES.s()local Format=__DARKLUA_BUNDLE_MODULES.i()local Panel=__DARKLUA_BUNDLE_MODULES.
z()local Rows=__DARKLUA_BUNDLE_MODULES.v()local Theme=__DARKLUA_BUNDLE_MODULES.r()local C=Theme.C local new,corner=
Create.new,Create.corner local CATEGORIES={'avatar','character','camera','visual','utility','hub'}local Commands={}
function Commands.build(panel,deps)panel.clear()local reg,t=deps.registry,deps.t local order=0 for _,cat in CATEGORIES
do local first=true for _,spec in reg.specs do if spec.category~=cat then continue end if first then order+=1 Rows.
group(panel.body,t('cat.'..cat),order)first=false end order+=1 local name=spec.name local on=reg:IsActive(name)local
disabled=reg:IsDisabled(name)or reg:Missing(spec)~=nil local row=Panel.row(panel.body,order,if Theme.touch then 40 else
32)row.BackgroundTransparency=1 new('Frame',{Name='Dot',Size=UDim2.fromOffset(5,5),BackgroundColor3=if on then C.accent
else C.control,LayoutOrder=1,Parent=row},{corner(3)})local label=name if spec.kind=='value'and on then label..=' '..
Format.value(reg:Value(name))end Create.text({text=label,size=13,color=if disabled then C.text3 elseif on then C.text1
else C.text2,auto=true},{LayoutOrder=2,Parent=row})Panel.spacer(row,3)local key=Rows.keyFor(deps.store,name)if key and
not Theme.touch then Controls.kbd(row,key).LayoutOrder=4 elseif deps.isPinned(name)then Controls.glyph('star',row,12,C.
text3).LayoutOrder=4 end Create.text({text=t('c.'..name),size=10,color=C.text3,auto=true},{LayoutOrder=5,Parent=row})
panel.content:Connect(row.MouseEnter,function()row.BackgroundTransparency=0 end)panel.content:Connect(row.MouseLeave,
function()row.BackgroundTransparency=1 end)panel.content:Connect(row.Activated,function()local req=Format.requiredArg(
spec)if spec.kind=='value'or req then deps.openBar(name..' ')else deps.run(name)end end)panel.content:Connect(row.
MouseButton2Click,function()deps.openBar(name)end)end end end return Commands end function __DARKLUA_BUNDLE_MODULES.B()
local v=__DARKLUA_BUNDLE_MODULES.cache.B if not v then v={c=__modImpl()}__DARKLUA_BUNDLE_MODULES.cache.B=v end return v.
c end end do local function __modImpl()local Common=__DARKLUA_BUNDLE_MODULES.w()local Controls=__DARKLUA_BUNDLE_MODULES.
t()local Create=__DARKLUA_BUNDLE_MODULES.s()local Drag=__DARKLUA_BUNDLE_MODULES.x()local FillBar=
__DARKLUA_BUNDLE_MODULES.u()local Format=__DARKLUA_BUNDLE_MODULES.i()local Janitor=__DARKLUA_BUNDLE_MODULES.j()local
Modules=__DARKLUA_BUNDLE_MODULES.o()local Theme=__DARKLUA_BUNDLE_MODULES.r()local Types=__DARKLUA_BUNDLE_MODULES.c()
local C,F,LINE,S=Theme.C,Theme.F,Theme.LINE,Theme.SIZE local new,corner,pad,list=Create.new,Create.corner,Create.pad,
Create.list local LONG_PRESS=0.45 local Dock={}local function presetsFor(spec)if spec.presets then return spec.presets
end local a1=spec.args and spec.args[1]local d=spec.default or(a1 and a1.min)or 1 local hi=(a1 and a1.max)or d*10 local
out={}for _,k in{1,2,4,6,9,12}do local v=math.min(hi,math.floor(d*k+0.5))if not table.find(out,v)then table.insert(out,v
)end end return out end function Dock.new(layer,jan,deps)local reg,t,store=deps.registry,deps.t,deps.store local touch=
Theme.touch local cellW,cellH=if touch then 60 else 56,if touch then 54 else 50 local frame=new('Frame',{Name='Dock',
AutomaticSize=Enum.AutomaticSize.XY,Size=UDim2.fromOffset(0,0),BackgroundColor3=C.surface,BackgroundTransparency=0.06,
Active=true,Parent=layer},{corner(S.card),Create.stroke(LINE.strong),pad(6,6,6,6),list('x',6)})Create.shadow(frame,Theme
.SHADOW.pop)local cellsJan=Janitor.new()jan:Add(cellsJan)local popJan=Janitor.new()jan:Add(popJan)local pop=nil local
popFor=nil local function placeDefault()local saved=store.data.dock if saved then Drag.place(frame,saved.x,saved.y)
elseif touch then Drag.place(frame,96,8)else Drag.place(frame,16,66)end end local closePopover local function 
openPopover(spec)closePopover()local a1=spec.args and spec.args[1]if not(a1 and a1.kind=='number')then deps.openBar(spec
.name..' ')return end local name=spec.name popFor=name local lo,hi=a1.min or 0,a1.max or 100 local card=new('Frame',{
Name='Popover',Size=UDim2.fromOffset(if touch then 400 else 380,0),AutomaticSize=Enum.AutomaticSize.Y,BackgroundColor3=C
.surface,Active=true,Parent=layer},{corner(S.card),Create.stroke(LINE.strong),pad(14,14,12,14),list('y',10)})Create.
shadow(card,Theme.SHADOW.pop)pop=card local head=new('Frame',{BackgroundTransparency=1,Size=UDim2.new(1,0,0,24),
LayoutOrder=1,Parent=card})local titles=new('Frame',{BackgroundTransparency=1,Size=UDim2.new(1,-30,1,0),Parent=head},{
list('x',8)})Create.text({text=t('c.'..name),size=14,font=F.medium,auto=true},{LayoutOrder=1,Parent=titles})if spec.
default then Create.text({text=t('dk.default',Format.value(spec.default)),size=12,color=C.text3,auto=true},{LayoutOrder=
2,Parent=titles})end local x=Controls.iconButton(head,'x',24)x.AnchorPoint=Vector2.new(1,0)x.Position=UDim2.fromScale(1,
0)popJan:Connect(x.Activated,function()closePopover()end)local h=if touch then 52 else 46 local ctl=new('Frame',{
BackgroundTransparency=1,Size=UDim2.new(1,0,0,h),LayoutOrder=2,Parent=card},{list('x',6)})local step=(a1.step or 1)*math
.max(1,math.floor((hi-lo)/100+0.5))local function nudge(delta)local cur=tonumber(reg:Value(name))or spec.default or lo
local v=math.clamp(cur+delta,lo,hi)deps.run(name..' '..Format.value(v))end local minus=Controls.iconButton(ctl,'minus',h
,true)minus.LayoutOrder=1 local barHolder=new('Frame',{BackgroundTransparency=1,Size=UDim2.new(1,-2*(h+6),1,0),
LayoutOrder=2,Parent=ctl})local bar=FillBar.new(barHolder,{height=h,min=lo,max=hi,step=a1.step or 1,default=spec.default
,jan=popJan,title=function()return''end,format=function(v)return Format.value(v)end,value=function()return tonumber(reg:
Value(name))or spec.default or lo end,active=function()return reg:IsActive(name)end,enabled=function()return true end,
commit=function(v)deps.run(name..' '..Format.value(v))end})local plus=Controls.iconButton(ctl,'plus',h,true)plus.
LayoutOrder=3 popJan:Connect(minus.Activated,function()nudge(-step)end)popJan:Connect(plus.Activated,function()nudge(
step)end)local presets=new('Frame',{BackgroundTransparency=1,Size=UDim2.new(1,0,0,if touch then 40 else 34),LayoutOrder=
3,Parent=card},{list('x',6)})local values=presetsFor(spec)for i,v in values do local current=reg:IsActive(name)and
tonumber(reg:Value(name))==v local b=new('TextButton',{Text=Format.value(v),AutoButtonColor=false,BackgroundColor3=if
current then Color3.fromHex('3b1a1d')else C.control,Size=UDim2.new(1/#values,-6*(#values-1)/#values,1,0),TextSize=12.5,
FontFace=F.mono,TextColor3=if current then C.accent else C.text1,LayoutOrder=i,AutoLocalize=false,Parent=presets},{
corner(S.radius)})popJan:Connect(b.Activated,function()deps.run(name..' '..Format.value(v))end)end local foot=new(
'Frame',{BackgroundTransparency=1,Size=UDim2.new(1,0,0,22),LayoutOrder=4,Parent=card})local reset=new('TextButton',{Text
=t('dk.reset'),AutoButtonColor=false,BackgroundTransparency=1,AutomaticSize=Enum.AutomaticSize.X,Size=UDim2.fromScale(0,
1),TextSize=13,FontFace=F.medium,TextColor3=C.text2,AutoLocalize=false,Parent=foot})local typeIt=reset:Clone()typeIt.
Text=t('dk.type')typeIt.AnchorPoint=Vector2.new(1,0)typeIt.Position=UDim2.fromScale(1,0)typeIt.Parent=foot popJan:
Connect(reset.Activated,function()deps.run('un'..name)end)popJan:Connect(typeIt.Activated,function()closePopover()deps.
openBar(name..' ')end)popJan:Add(reg.StateChanged:Connect(function(changed)if changed==name then bar.refresh()for _,b in
presets:GetChildren()do if b:IsA('TextButton')then local on=reg:IsActive(name)and tonumber(reg:Value(name))==tonumber(b.
Text)b.BackgroundColor3=if on then Color3.fromHex('3b1a1d')else C.control b.TextColor3=if on then C.accent else C.text1
end end end end))task.defer(function()if card.Parent then Drag.place(card,frame.Position.X.Offset,frame.Position.Y.
Offset+frame.AbsoluteSize.Y+8)end end)end closePopover=function()popJan:Cleanup()if pop then pop:Destroy()pop=nil end
popFor=nil end local function cell(name,w)return new('TextButton',{Name=name,Text='',AutoButtonColor=false,
BackgroundColor3=C.track,Size=UDim2.fromOffset(w,cellH),Parent=frame},{corner(S.radius)})end local function presetCell(
order,mod,pid)local M=deps.modules local preset=nil for _,p in M:Presets(mod)do if p.id==pid then preset=p end end if
not preset then return end local p=preset local on=M:PresetActive(mod,pid)local b=cell('Pin/preset:'..mod..':'..pid,
cellW)b.LayoutOrder=order b.BackgroundColor3=if on then C.accent else C.track local inner=new('Frame',{
BackgroundTransparency=1,Size=UDim2.fromScale(1,1),Parent=b},{pad(4,4,7,6)})local col=list('y',4)col.HorizontalAlignment
=Enum.HorizontalAlignment.Center col.VerticalAlignment=Enum.VerticalAlignment.Center col.Parent=inner Controls.glyph(
'sparkles',inner,16,if on then C.white else C.text2).LayoutOrder=1 Create.text({text=Create.marked(M:PresetTitle(mod,p),
nil),size=10,color=if on then C.white else C.text2,x=Enum.TextXAlignment.Center},{Size=UDim2.new(1,0,0,12),LayoutOrder=2
,Parent=inner})local pressAt=0 local longFired=false cellsJan:Connect(b.InputBegan,function(io)if io.UserInputType==Enum
.UserInputType.Touch or io.UserInputType==Enum.UserInputType.MouseButton1 then pressAt=os.clock()longFired=false local
stamp=pressAt task.delay(LONG_PRESS,function()if pressAt==stamp and b.Parent then longFired=true deps.openModule(mod)end
end)elseif io.UserInputType==Enum.UserInputType.MouseButton2 then deps.openModule(mod)end end)cellsJan:Connect(b.
InputEnded,function(io)if io.UserInputType==Enum.UserInputType.Touch or io.UserInputType==Enum.UserInputType.
MouseButton1 then pressAt=0 end end)cellsJan:Connect(b.Activated,function()if longFired then longFired=false return end
task.spawn(M.TogglePreset,M,mod,pid)end)end local function rebuild()cellsJan:Cleanup()for _,c in frame:GetChildren()do
if c:IsA('GuiObject')then c:Destroy()end end local open=cell('Open',if touch then 44 else 40)open.BackgroundTransparency
=1 open.LayoutOrder=0 local lg=Controls.logo(open,18)lg.AnchorPoint=Vector2.new(0.5,0.5)lg.Position=UDim2.fromScale(0.5,
0.5)local drag=Drag.attach(open,frame,cellsJan,function(x,y)store.data.dock={x=x,y=y}store:Save()end)cellsJan:Connect(
open.Activated,function()if not drag.moved()then deps.openBar(nil)end end)for i,name in store.data.pins do local mod,pid
=string.match(name,'^preset:([^:]+):(.+)$')if mod and pid then presetCell(i,mod,pid)continue end local spec=reg:Get(name
)if not spec or reg:IsDisabled(name)then continue end local on=reg:IsActive(name)local b=cell('Pin/'..name,cellW)b.
LayoutOrder=i b.BackgroundColor3=if on then C.accent else C.track local inner=new('Frame',{BackgroundTransparency=1,Size
=UDim2.fromScale(1,1),Parent=b},{pad(4,4,7,6)})local col=list('y',4)col.HorizontalAlignment=Enum.HorizontalAlignment.
Center col.VerticalAlignment=Enum.VerticalAlignment.Center col.Parent=inner if spec.kind=='value'then Create.text({text=
Format.value(reg:Value(name)),size=13,font=F.mono,color=if on then C.white else C.text1,x=Enum.TextXAlignment.Center},{
Size=UDim2.new(1,0,0,16),LayoutOrder=1,Parent=inner})else Controls.glyph(spec.icon or'command',inner,16,if on then C.
white else C.text2).LayoutOrder=1 end Create.text({text=t('c.'..name),size=10,color=if on then C.white else C.text2,x=
Enum.TextXAlignment.Center},{Size=UDim2.new(1,0,0,12),LayoutOrder=2,Parent=inner})local pressAt=0 local longFired=false
cellsJan:Connect(b.InputBegan,function(io)if io.UserInputType==Enum.UserInputType.Touch or io.UserInputType==Enum.
UserInputType.MouseButton1 then pressAt=os.clock()longFired=false local stamp=pressAt task.delay(LONG_PRESS,function()if
pressAt==stamp and b.Parent then longFired=true if spec.kind=='value'then openPopover(spec)else deps.openBar(name)end
end end)elseif io.UserInputType==Enum.UserInputType.MouseButton2 then if spec.kind=='value'then openPopover(spec)else
deps.openBar(name)end end end)cellsJan:Connect(b.InputEnded,function(io)if io.UserInputType==Enum.UserInputType.Touch or
io.UserInputType==Enum.UserInputType.MouseButton1 then pressAt=0 end end)cellsJan:Connect(b.Activated,function()if
longFired then longFired=false return end if popFor==name then closePopover()return end deps.quick(spec)end)end local
add=cell('Add',if touch then 40 else 34)add.LayoutOrder=99 add.BackgroundTransparency=1 Create.stroke(LINE.strong).
Parent=add local pg=Controls.glyph('plus',add,14,C.text2)pg.AnchorPoint=Vector2.new(0.5,0.5)pg.Position=UDim2.fromScale(
0.5,0.5)cellsJan:Connect(add.Activated,deps.openPins)end rebuild()task.defer(placeDefault)local queued=false local 
function soon()if queued then return end queued=true task.defer(function()queued=false if frame.Parent then rebuild()end
end)end jan:Add(reg.StateChanged:Connect(function()rebuild()end))jan:Add(deps.modules.Changed:Connect(function(_mod,what
)if what~='run'then soon()end end))return{frame=frame,rebuild=rebuild,popover=openPopover,closePopover=function()
closePopover()end,setVisible=function(v)frame.Visible=v if not v then closePopover()end end}end return Dock end function
__DARKLUA_BUNDLE_MODULES.C()local v=__DARKLUA_BUNDLE_MODULES.cache.C if not v then v={c=__modImpl()}
__DARKLUA_BUNDLE_MODULES.cache.C=v end return v.c end end do local function __modImpl()local StarterGui=game:GetService(
'StarterGui')local UserInputService=game:GetService('UserInputService')local Common=__DARKLUA_BUNDLE_MODULES.w()local
Controls=__DARKLUA_BUNDLE_MODULES.t()local Create=__DARKLUA_BUNDLE_MODULES.s()local Janitor=__DARKLUA_BUNDLE_MODULES.j()
local Theme=__DARKLUA_BUNDLE_MODULES.r()local C,F,LINE=Theme.C,Theme.F,Theme.LINE local new,corner,pad,list=Create.new,
Create.corner,Create.pad,Create.list local PER_PAGE=8 local KEYS={[Enum.KeyCode.One]=1,[Enum.KeyCode.Two]=2,[Enum.
KeyCode.Three]=3,[Enum.KeyCode.Four]=4,[Enum.KeyCode.Five]=5,[Enum.KeyCode.Six]=6,[Enum.KeyCode.Seven]=7,[Enum.KeyCode.
Eight]=8,[Enum.KeyCode.KeypadOne]=1,[Enum.KeyCode.KeypadTwo]=2,[Enum.KeyCode.KeypadThree]=3,[Enum.KeyCode.KeypadFour]=4,
[Enum.KeyCode.KeypadFive]=5,[Enum.KeyCode.KeypadSix]=6,[Enum.KeyCode.KeypadSeven]=7,[Enum.KeyCode.KeypadEight]=8}local
EmoteWheel={}local function setRobloxWheel(enabled)pcall(StarterGui.SetCoreGuiEnabled,StarterGui,Enum.CoreGuiType.
EmotesMenu,enabled)end function EmoteWheel.new(layer,jan,deps)local touch=Theme.touch local t,store=deps.t,deps.store
local W=if touch then 344 else 440 local SLOT=if touch then 72 else 84 local RING=if touch then 124 else 158 local
CENTER=if touch then 128 else 168 local overlay=nil local isOpen=false local pageNo=1 local list_={}local openJan=
Janitor.new()jan:Add(openJan)local hidden=false local floatBtn=nil local toggle local function applySetting()local on=
store.data.emoteWheel if on~=hidden then setRobloxWheel(not on)hidden=on end if touch then if on and not floatBtn then
local b=new('TextButton',{Name='EmoteButton',Text='',AutoButtonColor=false,AnchorPoint=Vector2.new(1,1),Position=UDim2.
new(1,-100,1,-186),Size=UDim2.fromOffset(56,56),BackgroundColor3=C.accent,Parent=layer},{corner(28),list('y',1,Enum.
VerticalAlignment.Center)})local l=b:FindFirstChildOfClass('UIListLayout')if l then l.HorizontalAlignment=Enum.
HorizontalAlignment.Center end Controls.glyph('sparkles',b,18,C.white).LayoutOrder=1 Create.text({text=t(
'avu.wheel_button'),size=9,font=F.medium,color=C.white,x=Enum.TextXAlignment.Center},{Size=UDim2.fromOffset(52,11),
LayoutOrder=2,Parent=b})jan:Connect(b.Activated,function()toggle()end)floatBtn=b elseif not on and floatBtn then
floatBtn:Destroy()floatBtn=nil end end end jan:Defer(function()if hidden then setRobloxWheel(true)end end)jan:Add(store.
Changed:Connect(function(key)if key=='emoteWheel'then applySetting()end end))applySetting()local close local function 
play(e)if e then deps.run('emote '..e.id)end close()end local function render()openJan:Cleanup()local o=overlay if o
then o:Destroy()end local root=new('TextButton',{Name='EmoteWheel',Text='',AutoButtonColor=false,BackgroundColor3=C.
black,BackgroundTransparency=0.65,Size=UDim2.fromScale(1,1),ZIndex=20,Parent=layer})overlay=root openJan:Add(root)
openJan:Connect(root.Activated,function()close()end)local pages=math.max(1,math.ceil(#list_/PER_PAGE))pageNo=math.clamp(
pageNo,1,pages)local wheel=new('Frame',{Name='Wheel',AnchorPoint=Vector2.new(0.5,0.5),Position=UDim2.fromScale(0.5,0.5),
Size=UDim2.fromOffset(W,W),BackgroundColor3=C.surface,BackgroundTransparency=0.08,Active=true,ZIndex=21,Parent=root},{
corner(W//2),Create.stroke(LINE.default)})Create.shadow(wheel,Theme.SHADOW.window)local center=new('Frame',{Name=
'Center',AnchorPoint=Vector2.new(0.5,0.5),Position=UDim2.fromScale(0.5,0.5),Size=UDim2.fromOffset(CENTER,CENTER),
BackgroundColor3=C.base,ZIndex=22,Parent=wheel},{corner(CENTER//2),Create.stroke(LINE.subtle),list('y',6,Enum.
VerticalAlignment.Center)})local cl=center:FindFirstChildOfClass('UIListLayout')if cl then cl.HorizontalAlignment=Enum.
HorizontalAlignment.Center end local cName=Create.text({text='',size=if touch then 16 else 20,font=F.semibold,x=Enum.
TextXAlignment.Center},{Name='Name',Size=UDim2.new(1,-20,0,24),ZIndex=23,LayoutOrder=1,Parent=center})local cSub=Create.
text({text='',size=10.5,font=F.mono,color=C.text3,x=Enum.TextXAlignment.Center},{Size=UDim2.new(1,-20,0,14),ZIndex=23,
LayoutOrder=2,Parent=center})local dots=new('Frame',{BackgroundTransparency=1,AutomaticSize=Enum.AutomaticSize.X,Size=
UDim2.fromOffset(0,6),LayoutOrder=3,Parent=center},{list('x',5)})for i=1,pages do new('Frame',{Size=UDim2.fromOffset(6,6
),BackgroundColor3=if i==pageNo then C.accent else C.text3,ZIndex=23,LayoutOrder=i,Parent=dots},{corner(3)})end local 
function show(i)local e=if i then list_[(pageNo-1)*PER_PAGE+i]else nil if e then cName.Text=Create.marked(e.name,nil)
cSub.Text=t('avu.slot',i)..(if e.fromOutfit then' \u{b7} '..t('avu.from_outfit')else'')elseif#list_==0 then cName.Text=
''cSub.Text=t('avu.wheel_empty')else cName.Text=''cSub.Text=if touch then t('avu.wheel_touch')else t('avu.page',pageNo,
pages)end end for i=1,PER_PAGE do local e=list_[(pageNo-1)*PER_PAGE+i]local a=(i-1)*math.pi/4 local b=new('TextButton',{
Name='Slot/'..i,Text='',AutoButtonColor=false,AnchorPoint=Vector2.new(0.5,0.5),Position=UDim2.new(0.5,RING*math.sin(a),
0.5,-RING*math.cos(a)),Size=UDim2.fromOffset(SLOT,SLOT),BackgroundColor3=C.surface,BackgroundTransparency=if e then 0
else 0.5,ZIndex=22,Parent=wheel},{corner(SLOT//2),Create.stroke(LINE.strong),pad(6,6),list('y',2,Enum.VerticalAlignment.
Center)})local bl=b:FindFirstChildOfClass('UIListLayout')if bl then bl.HorizontalAlignment=Enum.HorizontalAlignment.
Center end if e then new('ImageLabel',{BackgroundTransparency=1,Size=UDim2.fromOffset(if touch then 22 else 26,if touch
then 22 else 26),Image=string.format('rbxthumb://type=Asset&id=%d&w=150&h=150',e.id),ZIndex=23,LayoutOrder=1,Parent=b})
Create.text({text=Create.marked(e.name,nil),size=11,font=F.medium,x=Enum.TextXAlignment.Center},{Size=UDim2.new(1,0,0,14
),ZIndex=23,LayoutOrder=2,Parent=b})end Create.text({text=tostring(i),size=9.5,font=F.mono,color=C.text3,x=Enum.
TextXAlignment.Center},{Size=UDim2.new(1,0,0,11),ZIndex=23,LayoutOrder=3,Parent=b})openJan:Connect(b.MouseEnter,function
()if e then b.BackgroundColor3=C.accent show(i)end end)openJan:Connect(b.MouseLeave,function()b.BackgroundColor3=C.
surface show(nil)end)openJan:Connect(b.Activated,function()play(e)end)end show(nil)if not touch then for _,side in{{'Q',
'arrow-left',-1},{'E','arrow-right',1}}do local key,icon,dir=side[1],side[2],side[3]local b=new('TextButton',{Name=
'Page'..key,Text='',AutoButtonColor=false,AnchorPoint=Vector2.new(0.5,0.5),Position=UDim2.new(0.5,dir*(W/2+48),0.5,0),
Size=UDim2.fromOffset(56,72),BackgroundColor3=C.surface,BackgroundTransparency=0.08,ZIndex=21,Parent=root},{corner(12),
Create.stroke(LINE.default),list('y',6,Enum.VerticalAlignment.Center)})local l=b:FindFirstChildOfClass('UIListLayout')if
l then l.HorizontalAlignment=Enum.HorizontalAlignment.Center end Controls.glyph(icon,b,16,C.text2).LayoutOrder=1
Controls.kbd(b,key).LayoutOrder=2 openJan:Connect(b.Activated,function()pageNo=(pageNo-1+dir)%pages+1 render()end)end
local hints=new('Frame',{Name='Hints',AnchorPoint=Vector2.new(0.5,0),Position=UDim2.new(0.5,0,0.5,W/2+28),AutomaticSize=
Enum.AutomaticSize.X,Size=UDim2.fromOffset(0,36),BackgroundColor3=C.surface,BackgroundTransparency=0.06,ZIndex=21,Parent
=root},{corner(10),Create.stroke(LINE.subtle),pad(14,14),list('x',8)})local n=0 for _,h in{{'1\u{2013}8',
'avu.wheel_play'},{'Q / E','avu.wheel_page'},{'\u{21c5}','avu.wheel_scroll'},{'Esc','avu.wheel_close'}}do n+=1 Controls.
kbd(hints,h[1]).LayoutOrder=n n+=1 Create.text({text=t(h[2]),size=12,color=C.text2,auto=true},{LayoutOrder=n,Parent=
hints})end end local swipeFrom=nil openJan:Connect(wheel.InputBegan,function(io)if io.UserInputType==Enum.UserInputType.
Touch then swipeFrom=io.Position end end)openJan:Connect(wheel.InputEnded,function(io)local from=swipeFrom if from and
io.UserInputType==Enum.UserInputType.Touch then swipeFrom=nil local dx=io.Position.X-from.X if math.abs(dx)>60 and pages
>1 then pageNo=(pageNo-1+(if dx<0 then 1 else-1))%pages+1 render()end end end)end local function open()if isOpen then
return end local api=deps.registry:Api('avatar')if not api then return end list_=api.Wheel()isOpen=true pageNo=1 render(
)end close=function()if not isOpen then return end isOpen=false openJan:Cleanup()overlay=nil end toggle=function()if
isOpen then close()else task.spawn(open)end end jan:Connect(UserInputService.InputBegan,function(io,processed)if
processed or UserInputService:GetFocusedTextBox()then return end local kc=io.KeyCode if kc==Enum.KeyCode.Period and
store.data.emoteWheel then toggle()return end if not isOpen then return end if kc==Enum.KeyCode.Escape then close()
elseif kc==Enum.KeyCode.Q or kc==Enum.KeyCode.E then local pages=math.max(1,math.ceil(#list_/PER_PAGE))pageNo=(pageNo-1+
(if kc==Enum.KeyCode.E then 1 else-1))%pages+1 render()else local slot=KEYS[kc]if slot then play(list_[(pageNo-1)*
PER_PAGE+slot])end end end)jan:Connect(UserInputService.InputChanged,function(io)if isOpen and io.UserInputType==Enum.
UserInputType.MouseWheel then local pages=math.max(1,math.ceil(#list_/PER_PAGE))if pages>1 then pageNo=(pageNo-1+(if io.
Position.Z<0 then 1 else-1))%pages+1 render()end end end)return{open=function()task.spawn(open)end,close=function()
close()end,toggle=function()toggle()end,isOpen=function()return isOpen end,frame=function()return overlay end}end return
EmoteWheel end function __DARKLUA_BUNDLE_MODULES.D()local v=__DARKLUA_BUNDLE_MODULES.cache.D if not v then v={c=
__modImpl()}__DARKLUA_BUNDLE_MODULES.cache.D=v end return v.c end end do local function __modImpl()local Controls=
__DARKLUA_BUNDLE_MODULES.t()local Create=__DARKLUA_BUNDLE_MODULES.s()local Janitor=__DARKLUA_BUNDLE_MODULES.j()local
Theme=__DARKLUA_BUNDLE_MODULES.r()local C,F,LINE,S=Theme.C,Theme.F,Theme.LINE,Theme.SIZE local new,corner,pad,list=
Create.new,Create.corner,Create.pad,Create.list local Launcher={}function Launcher.new(layer,jan,label,key,onOpen)local
b=new('TextButton',{Name='Launcher',Text='',AutoButtonColor=false,AnchorPoint=Vector2.new(1,0),Position=UDim2.new(1,-16,
0,12),AutomaticSize=Enum.AutomaticSize.X,Size=UDim2.fromOffset(0,34),BackgroundColor3=C.surface,BackgroundTransparency=
0.06,Parent=layer},{corner(S.radius+2),Create.stroke(LINE.strong),pad(10,6),list('x',8)})Controls.logo(b,14).LayoutOrder
=1 Create.text({text=label,size=13,font=F.medium,auto=true},{Name='Label',LayoutOrder=2,Parent=b})Controls.kbd(b,key).
LayoutOrder=3 jan:Connect(b.Activated,onOpen)return b end return Launcher end function __DARKLUA_BUNDLE_MODULES.E()local
v=__DARKLUA_BUNDLE_MODULES.cache.E if not v then v={c=__modImpl()}__DARKLUA_BUNDLE_MODULES.cache.E=v end return v.c end
end do local function __modImpl()local Common=__DARKLUA_BUNDLE_MODULES.w()local Create=__DARKLUA_BUNDLE_MODULES.s()local
Log=__DARKLUA_BUNDLE_MODULES.e()local Panel=__DARKLUA_BUNDLE_MODULES.z()local Theme=__DARKLUA_BUNDLE_MODULES.r()local C,
F=Theme.C,Theme.F local LogPanel={}function LogPanel.build(panel,deps)panel.clear()local n=0 local function add(e)n+=1
local color=if e.level=='error'then C.accent elseif e.level=='warn'then C.text1 else C.text2 Create.text({text=os.date(
'%H:%M:%S',e.time)..'  '..Create.marked(e.text,nil),size=11,font=F.mono,color=color},{Size=UDim2.fromScale(1,0),
AutomaticSize=Enum.AutomaticSize.Y,TextWrapped=true,TextTruncate=Enum.TextTruncate.None,LayoutOrder=n,Parent=panel.body}
)end for _,e in deps.log:Entries()do add(e)end if n==0 then Create.text({text=deps.t('set.log_empty'),size=12,color=C.
text3},{Size=UDim2.new(1,0,0,24),Parent=panel.body})end panel.content:Add(deps.log.Added:Connect(add))end return
LogPanel end function __DARKLUA_BUNDLE_MODULES.F()local v=__DARKLUA_BUNDLE_MODULES.cache.F if not v then v={c=__modImpl(
)}__DARKLUA_BUNDLE_MODULES.cache.F=v end return v.c end end do local function __modImpl()local UserInputService=game:
GetService('UserInputService')local Common=__DARKLUA_BUNDLE_MODULES.w()local Controls=__DARKLUA_BUNDLE_MODULES.t()local
Create=__DARKLUA_BUNDLE_MODULES.s()local Drag=__DARKLUA_BUNDLE_MODULES.x()local FillBar=__DARKLUA_BUNDLE_MODULES.u()
local Format=__DARKLUA_BUNDLE_MODULES.i()local Janitor=__DARKLUA_BUNDLE_MODULES.j()local Theme=__DARKLUA_BUNDLE_MODULES.
r()local Types=__DARKLUA_BUNDLE_MODULES.c()local C,F,LINE,S=Theme.C,Theme.F,Theme.LINE,Theme.SIZE local new,corner,pad,
list=Create.new,Create.corner,Create.pad,Create.list local ON_BG=Color3.fromHex('2a1416')local PRESET_ON=Color3.fromHex(
'3b1a1d')local ModulePanel={}function ModulePanel.new(layer,jan,deps,mod)local touch=Theme.touch local M,t,store=deps.
modules,deps.t,deps.store local spec=(M:Get(mod))local W=if touch then S.panelTouch else 760 local CELL=if touch then 40
else 34 local function key(suffix)return'm.'..mod..'.'..suffix end local frame=new('Frame',{Name='Module/'..mod,Size=
UDim2.fromOffset(W,0),AutomaticSize=Enum.AutomaticSize.Y,BackgroundColor3=C.surface,Visible=false,Active=true,Parent=
layer},{corner(if touch then S.card else S.window),Create.stroke(LINE.strong),list('y',0)})Create.shadow(frame,Theme.
SHADOW.window)local section=spec.sections[1]local query=''local isOpen=false local bodyJan=Janitor.new()jan:Add(bodyJan)
local header=new('Frame',{Name='Header',BackgroundTransparency=1,Size=UDim2.new(1,0,0,if touch then 48 else 50),
LayoutOrder=1,Active=true,Parent=frame},{pad(14,10)})local hl=new('Frame',{BackgroundTransparency=1,Size=UDim2.
fromScale(0.6,1),Parent=header},{list('x',9)})Controls.logo(hl,15).LayoutOrder=1 Create.text({text=t(key('title')),size=
14,font=F.semibold,auto=true},{LayoutOrder=2,Parent=hl})if spec.badge then local tint=Color3.fromHex(spec.badgeColor or
'ff9c48')local badge=Create.text({text=spec.badge,size=10.5,font=F.medium,color=tint,auto=true},{Size=UDim2.fromOffset(0
,20),BackgroundTransparency=0.84,BackgroundColor3=tint,LayoutOrder=3,Parent=hl})corner(5).Parent=badge pad(7,7).Parent=
badge end local count=Create.text({text='',size=10.5,font=F.mono,color=C.text3,auto=true},{LayoutOrder=4,Parent=hl})
local hr=new('Frame',{BackgroundTransparency=1,AnchorPoint=Vector2.new(1,0),Position=UDim2.fromScale(1,0),Size=UDim2.
fromScale(0.4,1),Parent=header})local hrl=list('x',6)hrl.HorizontalAlignment=Enum.HorizontalAlignment.Right hrl.Parent=
hr local search=new('Frame',{Name='Search',BackgroundColor3=C.track,Size=UDim2.fromOffset(if touch then 150 else 200,if
touch then 34 else 30),LayoutOrder=1,Parent=hr},{corner(S.radius),pad(10,8)})Controls.glyph('search',search,13,C.text3).
Position=UDim2.new(0,0,0.5,-6)local searchBox=new('TextBox',{Name='Query',BackgroundTransparency=1,Position=UDim2.
fromOffset(20,0),Size=UDim2.new(1,-20,1,0),Text='',PlaceholderText=t('md.search'),PlaceholderColor3=C.text3,TextColor3=C
.text1,TextSize=12.5,FontFace=F.regular,TextXAlignment=Enum.TextXAlignment.Left,ClearTextOnFocus=false,AutoLocalize=
false,Parent=search})local close=Controls.iconButton(hr,'x')close.LayoutOrder=2 local presets if touch then presets=new(
'ScrollingFrame',{Name='Presets',BackgroundTransparency=1,BorderSizePixel=0,Size=UDim2.new(1,0,0,44),CanvasSize=UDim2.
fromScale(0,0),AutomaticCanvasSize=Enum.AutomaticSize.X,ScrollingDirection=Enum.ScrollingDirection.X,ScrollBarThickness=
0,LayoutOrder=2,Parent=frame},{pad(14,14,0,10),list('x',6)})else presets=new('Frame',{Name='Presets',
BackgroundTransparency=1,Size=UDim2.fromScale(1,0),AutomaticSize=Enum.AutomaticSize.Y,LayoutOrder=2,Parent=frame},{pad(
14,14,6,10)})new('UIListLayout',{FillDirection=Enum.FillDirection.Horizontal,Wraps=true,Padding=UDim.new(0,6),SortOrder=
Enum.SortOrder.LayoutOrder,VerticalAlignment=Enum.VerticalAlignment.Center,Parent=presets})end Controls.hairline(frame,3
)local body=new('Frame',{Name='Body',BackgroundTransparency=1,Size=UDim2.new(1,0,0,if touch then 0 else 360),
AutomaticSize=if touch then Enum.AutomaticSize.Y else Enum.AutomaticSize.None,LayoutOrder=4,Parent=frame})local NAV=if
touch then 0 else 170 local nav=nil local tabs=nil if touch then tabs=new('ScrollingFrame',{Name='Sections',
BackgroundTransparency=1,BorderSizePixel=0,Size=UDim2.new(1,0,0,44),CanvasSize=UDim2.fromScale(0,0),AutomaticCanvasSize=
Enum.AutomaticSize.X,ScrollingDirection=Enum.ScrollingDirection.X,ScrollBarThickness=0,Parent=body},{pad(10,10,6,4),
list('x',6)})else nav=new('ScrollingFrame',{Name='Sections',BackgroundTransparency=1,BorderSizePixel=0,Size=UDim2.new(0,
NAV,1,0),CanvasSize=UDim2.fromScale(0,0),AutomaticCanvasSize=Enum.AutomaticSize.Y,ScrollingDirection=Enum.
ScrollingDirection.Y,ScrollBarThickness=3,ScrollBarImageColor3=C.text3,Parent=body},{pad(8,8,10,10),list('y',2)})new(
'Frame',{BackgroundColor3=C.white,BackgroundTransparency=LINE.default,BorderSizePixel=0,Position=UDim2.fromOffset(NAV,0)
,Size=UDim2.new(0,1,1,0),Parent=body})end local content=new('ScrollingFrame',{Name='Content',BackgroundTransparency=1,
BorderSizePixel=0,Position=UDim2.fromOffset(if touch then 0 else NAV+1,if touch then 44 else 0),Size=if touch then UDim2
.fromScale(1,0)else UDim2.new(1,-NAV-1,1,0),CanvasSize=UDim2.fromScale(0,0),AutomaticCanvasSize=Enum.AutomaticSize.Y,
ScrollingDirection=Enum.ScrollingDirection.Y,ScrollBarThickness=3,ScrollBarImageColor3=C.text3,Parent=body},{pad(if
touch then 10 else 14,if touch then 10 else 14,if touch then 4 else 12,12),list('y',6)})if touch then Create.fitScroll(
content,function()return 190 end)content.Position=UDim2.fromOffset(0,0)list('y',0).Parent=body if tabs then tabs.
LayoutOrder=1 end content.LayoutOrder=2 end local runRow=nil local runDot,runText,runTime,runBar,runStart,runStop if
spec.runner then Controls.hairline(frame,5)local r=new('Frame',{Name='Run',BackgroundTransparency=1,Size=UDim2.new(1,0,0
,if touch then 50 else 48),LayoutOrder=6,Parent=frame},{pad(14,10),list('x',10)})runRow=r runDot=new('Frame',{Size=UDim2
.fromOffset(8,8),BackgroundColor3=C.text3,LayoutOrder=1,Parent=r},{corner(4)})runText=Create.text({text='',size=13,font=
F.medium,auto=true},{LayoutOrder=2,Parent=r})runTime=Create.text({text='',size=11,font=F.mono,color=C.text3,auto=true},{
LayoutOrder=3,Parent=r})local prog=new('Frame',{Size=UDim2.fromOffset(if touch then 70 else 140,4),BackgroundColor3=C.
control,LayoutOrder=4,ClipsDescendants=true,Parent=r},{corner(2)})runBar=new('Frame',{Size=UDim2.fromScale(0,1),
BackgroundColor3=C.ok,Parent=prog},{corner(2)})local sp=new('Frame',{BackgroundTransparency=1,Size=UDim2.fromScale(0,1),
LayoutOrder=5,Parent=r})pcall(function()new('UIFlexItem',{FlexMode=Enum.UIFlexMode.Fill,Parent=sp})end)runStart=Controls
.button(r,t('md.start'),'accent','zap')runStart.LayoutOrder=6 runStop=Controls.button(r,t('md.stop'),'ghost')runStop.
LayoutOrder=7 end local function updateRun()if not runRow then return end local run=M:Run(mod)local state=run.state
runDot.BackgroundColor3=if state=='running'then C.ok elseif state=='paused'then Color3.fromHex('f5b544')else C.text3
local status=run.status if status==''then status=if state=='idle'then t(key('run'))else t('md.'..state)end runText.Text=
Create.marked(status,nil)local secs=math.floor(run.elapsed())runTime.Text=if state=='idle'then''else string.format(
'%02d:%02d',secs//60,secs%60)runBar.Size=UDim2.fromScale(run.progress,1)local label=(runStart:FindFirstChild('Label'))if
label then label.Text=if state=='running'then t('md.pause')elseif state=='paused'then t('md.resume')else t('md.start')
end runStop.Visible=state~='idle'end local function clear(f)for _,c in f:GetChildren()do if c:IsA('GuiObject')then c:
Destroy()end end end local function grid(parent,order,cols,n,h)local cells={}local rows=math.ceil(n/cols)for r=1,rows do
local row=new('Frame',{BackgroundTransparency=1,Size=UDim2.new(1,0,0,h),LayoutOrder=order+r/100,Parent=parent},{list('x'
,6)})for c=1,cols do if(r-1)*cols+c>n then break end table.insert(cells,new('Frame',{BackgroundTransparency=1,Size=UDim2
.new(1/cols,-6*(cols-1)/cols,1,0),LayoutOrder=c,Parent=row}))end end return cells end local function checkCell(cell,f)
local on=M:IsOn(mod,f.id)local b=new('TextButton',{Name='Check/'..f.id,Text='',AutoButtonColor=false,BackgroundColor3=if
on then ON_BG else C.track,Size=UDim2.fromScale(1,1),Parent=cell},{corner(S.radius),pad(10,8)})Create.text({text=t(key(
'f.'..f.id)),size=12.5},{Size=UDim2.new(1,-26,1,0),Parent=b})local ck=Controls.check(b)ck.frame.AnchorPoint=Vector2.new(
1,0.5)ck.frame.Position=UDim2.fromScale(1,0.5)ck.set(on)bodyJan:Connect(b.Activated,function()task.spawn(function()local
ok,msg=M:Set(mod,f.id,not M:IsOn(mod,f.id))if not ok and msg then deps.toast('error',msg)end end)end)end local function 
paramCell(cell,f)if f.kind=='number'then local bar=FillBar.new(cell,{height=CELL,min=f.min or 0,max=f.max or 100,step=f.
step or 1,default=f.default,scroll=content,jan=bodyJan,title=function()return t(key('f.'..f.id))end,format=function(v)
return Format.value(v)end,value=function()return tonumber(M:Value(mod,f.id))or f.default or 0 end,active=function()
return M:IsOn(mod,f.id)end,enabled=function()return true end,commit=function(v)task.spawn(M.Set,M,mod,f.id,v)end})bar.
frame.Name='Param/'..f.id bodyJan:Connect(bar.frame.MouseButton2Click,function()task.spawn(M.Set,M,mod,f.id,nil)end)
return end local on=M:IsOn(mod,f.id)local b=new('TextButton',{Name='Param/'..f.id,Text='',AutoButtonColor=false,
BackgroundColor3=if on then ON_BG else C.track,Size=UDim2.fromScale(1,1),Parent=cell},{corner(S.radius),pad(12,8)})
Create.text({text=t(key('f.'..f.id)),size=12.5,color=C.text3},{Size=UDim2.fromScale(0.5,1),Parent=b})local v=M:Value(mod
,f.id)Create.text({text=t(key('o.'..tostring(v))),size=12.5,color=if on then C.text1 else C.text2,x=Enum.TextXAlignment.
Right},{AnchorPoint=Vector2.new(1,0),Position=UDim2.new(1,-18,0,0),Size=UDim2.new(0.5,-18,1,0),Parent=b})local chev=
Controls.glyph('chevron-down',b,13,C.text3)chev.AnchorPoint=Vector2.new(1,0.5)chev.Position=UDim2.fromScale(1,0.5)
bodyJan:Connect(b.Activated,function()local opts=f.options or{}local i=table.find(opts,M:Value(mod,f.id))or 0 local
nextV=if M:IsOn(mod,f.id)then opts[i%#opts+1]else opts[math.max(i,1)]if M:IsOn(mod,f.id)and i==#opts then nextV=nil end
task.spawn(M.Set,M,mod,f.id,nextV)end)bodyJan:Connect(b.MouseButton2Click,function()task.spawn(M.Set,M,mod,f.id,nil)end)
end local renderBody local function renderPresets()clear(presets)if not touch then Controls.eyebrow(presets,t(
'md.presets')).LayoutOrder=0 end for i,p in M:Presets(mod)do local active=M:PresetActive(mod,p.id)local name=p.name or
t(key('p.'..p.id))local n=0 for _ in p.values do n+=1 end local chip=new('TextButton',{Name='Preset/'..p.id,Text='',
AutoButtonColor=false,AutomaticSize=Enum.AutomaticSize.X,Size=UDim2.fromOffset(0,if touch then 34 else 30),
BackgroundColor3=if active then PRESET_ON else C.control,LayoutOrder=i,Parent=presets},{corner(S.radius),pad(10,10),
list('x',6)})if active then new('Frame',{Size=UDim2.fromOffset(6,6),BackgroundColor3=C.accent,LayoutOrder=1,Parent=chip}
,{corner(3)})end Create.text({text=Create.marked(name,nil),size=12.5,font=F.medium,auto=true},{LayoutOrder=2,Parent=chip
})Create.text({text=tostring(n),size=10.5,font=F.mono,color=C.text3,auto=true},{LayoutOrder=3,Parent=chip})if deps.
isPinned('preset:'..mod..':'..p.id)then Controls.glyph('star',chip,11,C.accent).LayoutOrder=4 end bodyJan:Connect(chip.
Activated,function()task.spawn(M.TogglePreset,M,mod,p.id)end)bodyJan:Connect(chip.MouseButton2Click,function()if not p.
builtin and UserInputService:IsKeyDown(Enum.KeyCode.LeftShift)then M:DeletePreset(mod,p.id)else deps.togglePin('preset:'
..mod..':'..p.id)renderPresets()end end)end local save=new('TextButton',{Name='SavePreset',Text='',AutoButtonColor=false
,AutomaticSize=Enum.AutomaticSize.X,Size=UDim2.fromOffset(0,if touch then 34 else 30),BackgroundTransparency=1,
LayoutOrder=90,Parent=presets},{corner(S.radius),Create.stroke(LINE.strong),pad(10,10),list('x',5)})Controls.glyph(
'plus',save,12,C.text2).LayoutOrder=1 Create.text({text=t('md.save'),size=12.5,color=C.text2,auto=true},{LayoutOrder=2,
Parent=save})bodyJan:Connect(save.Activated,function()local n=#(store.data.modules[mod]and store.data.modules[mod].
presets or{})+1 M:SavePreset(mod,t('md.my_preset',n))deps.toast('ok',t('md.saved'))end)local off=Controls.button(presets
,t('md.all_off'),'ghost')off.LayoutOrder=91 bodyJan:Connect(off.Activated,function()task.spawn(M.AllOff,M,mod)end)end
local function renderSections()local holder=if touch then tabs else nav clear(holder)for i,s in spec.sections do local
on,total=M:Count(mod,s)local selected=s==section and query==''local b=new('TextButton',{Name='Section/'..s,Text='',
AutoButtonColor=false,BackgroundColor3=C.control,BackgroundTransparency=if selected then 0 else 1,AutomaticSize=if touch
then Enum.AutomaticSize.X else Enum.AutomaticSize.None,Size=if touch then UDim2.fromOffset(0,34)else UDim2.new(1,0,0,34)
,LayoutOrder=i,Parent=holder},{corner(S.radius),pad(10,10),list('x',8)})Create.text({text=t(key('s.'..s)),size=13,font=F
.medium,color=if selected then C.text1 else C.text2,auto=true},{LayoutOrder=1,Parent=b})if not touch then local sp=new(
'Frame',{BackgroundTransparency=1,Size=UDim2.fromScale(0,1),LayoutOrder=2,Parent=b})pcall(function()new('UIFlexItem',{
FlexMode=Enum.UIFlexMode.Fill,Parent=sp})end)end local cnt=Create.text({text=on..'/'..total,size=10.5,font=F.mono,color=
if on>0 then Color3.fromHex('ff8a93')else C.text3,auto=true},{Size=UDim2.fromOffset(0,18),BackgroundTransparency=if on>0
then 0.84 else 1,BackgroundColor3=C.accent,LayoutOrder=3,Parent=b})corner(4).Parent=cnt pad(5,5).Parent=cnt bodyJan:
Connect(b.Activated,function()section=s query=''searchBox.Text=''renderBody()end)end if touch and tabs then local allOn=
select(1,M:Count(mod,section))==0 local b=Controls.button(tabs,if allOn then t('md.section_on')else t('md.section_off'),
'plain')b.LayoutOrder=99 b.Size=UDim2.fromOffset(0,34)bodyJan:Connect(b.Activated,function()task.spawn(M.SetSection,M,
mod,section,allOn)end)end end local function matchesQuery(f)if query==''then return f.section==section end local title=
string.lower(t(key('f.'..f.id)))return string.find(title,string.lower(query),1,true)~=nil or string.find(string.lower(f.
id),string.lower(query),1,true)~=nil end local function renderContent()clear(content)local toggles={}local params={}for
_,f in spec.features do if matchesQuery(f)then table.insert(if f.kind=='toggle'then toggles else params,f)end end local
order=1 if not touch then local head=new('Frame',{BackgroundTransparency=1,Size=UDim2.new(1,0,0,34),LayoutOrder=order,
Parent=content})local hlist=new('Frame',{BackgroundTransparency=1,Size=UDim2.fromScale(0.6,1),Parent=head},{list('x',8)}
)local titleText=if query==''then t(key('s.'..section))else t('md.found',#toggles+#params)Create.text({text=Create.
marked(titleText,nil),size=20,font=F.medium,auto=true},{LayoutOrder=1,Parent=hlist})if query==''then local on,total=M:
Count(mod,section)Create.text({text=t('md.of',on,total),size=10.5,font=F.mono,color=C.text3,auto=true},{LayoutOrder=2,
Parent=hlist})local hb=new('Frame',{BackgroundTransparency=1,AnchorPoint=Vector2.new(1,0.5),Position=UDim2.fromScale(1,
0.5),Size=UDim2.fromScale(0.4,1),Parent=head})local hbl=list('x',6)hbl.HorizontalAlignment=Enum.HorizontalAlignment.
Right hbl.Parent=hb local allOn=Controls.button(hb,t('md.section_on'),'plain')allOn.LayoutOrder=1 local allOff=Controls.
button(hb,t('md.section_off'),'plain')allOff.LayoutOrder=2 bodyJan:Connect(allOn.Activated,function()task.spawn(M.
SetSection,M,mod,section,true)end)bodyJan:Connect(allOff.Activated,function()task.spawn(M.SetSection,M,mod,section,false
)end)end end order+=1 local cols=3 for i,cell in grid(content,order,cols,#toggles,CELL)do checkCell(cell,toggles[i])end
order+=1 if#params>0 then local eb=new('Frame',{BackgroundTransparency=1,Size=UDim2.new(1,0,0,22),LayoutOrder=order,
Parent=content},{pad(2,2,6,0)})Controls.eyebrow(eb,t('md.params'))order+=1 for i,cell in grid(content,order,if touch
then 1 else cols,#params,if touch then S.rowTouch else CELL)do paramCell(cell,params[i])end end if#toggles+#params==0
then Create.text({text=t('ui.nothing'),size=13,color=C.text3},{Size=UDim2.new(1,0,0,30),LayoutOrder=order+1,Parent=
content})end end renderBody=function()bodyJan:Cleanup()local on,total=M:Count(mod)count.Text=t('md.of',on,total)
renderPresets()renderSections()renderContent()updateRun()end jan:Connect(close.Activated,function()isOpen=false frame.
Visible=false end)jan:Connect(searchBox:GetPropertyChangedSignal('Text'),function()query=searchBox.Text if isOpen then
renderBody()end end)if runRow then jan:Connect(runStart.Activated,function()local state=M:Run(mod).state if state==
'running'then M:Pause(mod)else M:Start(mod)end end)jan:Connect(runStop.Activated,function()M:Stop(mod)end)end local
queued=false jan:Add(M.Changed:Connect(function(changed,what)if changed~=mod or not isOpen then return end if what==
'run'then updateRun()elseif not queued then queued=true task.defer(function()queued=false if isOpen and frame.Parent
then renderBody()end end)end end))local ticking=true jan:Defer(function()ticking=false end)task.spawn(function()while
ticking do task.wait(1)if ticking and isOpen and M:Run(mod).state~='idle'then updateRun()end end end)Drag.attach(header,
frame,jan,function(x,y)if not touch then store.data.panels['module:'..mod]={x=x,y=y}store:Save()end end)return{frame=
frame,open=function()isOpen=true frame.Visible=true renderBody()task.defer(function()local vp=Drag.viewport()local saved
=store.data.panels['module:'..mod]if touch then Drag.place(frame,(vp.X-W)/2,0)elseif saved then Drag.place(frame,saved.x
,saved.y)else Drag.place(frame,(vp.X-W)/2,96)end end)end,close=function()isOpen=false frame.Visible=false end,isOpen=
function()return isOpen end}end return ModulePanel end function __DARKLUA_BUNDLE_MODULES.G()local v=
__DARKLUA_BUNDLE_MODULES.cache.G if not v then v={c=__modImpl()}__DARKLUA_BUNDLE_MODULES.cache.G=v end return v.c end
end do local function __modImpl()local Common=__DARKLUA_BUNDLE_MODULES.w()local Controls=__DARKLUA_BUNDLE_MODULES.t()
local Create=__DARKLUA_BUNDLE_MODULES.s()local Format=__DARKLUA_BUNDLE_MODULES.i()local Panel=__DARKLUA_BUNDLE_MODULES.
z()local Theme=__DARKLUA_BUNDLE_MODULES.r()local C,F=Theme.C,Theme.F local Pins={}Pins.MAX=6 function Pins.build(panel,
deps,done)panel.clear()local reg,t,store=deps.registry,deps.t,deps.store panel.setTitle(t('pn.pins')..'  '..#store.data.
pins..'/'..Pins.MAX)local order=0 for _,spec in reg.specs do if spec.category=='hub'or Format.requiredArg(spec)and spec.
kind~='value'then continue end order+=1 local name=spec.name local pinned=deps.isPinned(name)local row=Panel.row(panel.
body,order)Controls.glyph(spec.icon or'command',row,14,C.text2).LayoutOrder=1 Create.text({text=t('c.'..name),size=13,
auto=true},{LayoutOrder=2,Parent=row})Create.text({text=name,size=10.5,font=F.mono,color=C.text3,auto=true},{LayoutOrder
=3,Parent=row})Panel.spacer(row,4)Controls.glyph('star',row,16,if pinned then C.accent else C.text3).LayoutOrder=5 panel
.content:Connect(row.Activated,function()if not pinned and#store.data.pins>=Pins.MAX then return end deps.togglePin(name
)Pins.build(panel,deps,done)end)end local M=deps.modules for _,s in M:Available()do for _,p in M:Presets(s.id)do order+=
1 local key='preset:'..s.id..':'..p.id local pinned=deps.isPinned(key)local row=Panel.row(panel.body,order)row.Name=
'Row/'..key Controls.glyph('sparkles',row,14,C.text2).LayoutOrder=1 Create.text({text=Create.marked(M:PresetTitle(s.id,p
),nil),size=13,auto=true},{LayoutOrder=2,Parent=row})Create.text({text=Create.marked(t('m.'..s.id..'.title'),nil),size=
10.5,color=C.text3,auto=true},{LayoutOrder=3,Parent=row})Panel.spacer(row,4)Controls.glyph('star',row,16,if pinned then
C.accent else C.text3).LayoutOrder=5 panel.content:Connect(row.Activated,function()if not pinned and#store.data.pins>=
Pins.MAX then return end deps.togglePin(key)Pins.build(panel,deps,done)end)end end order+=1 local ok=Controls.button(
panel.body,t('dk.done'),'accent','check')ok.AutomaticSize=Enum.AutomaticSize.None ok.Size=UDim2.new(1,0,0,if Theme.touch
then 40 else 34)ok.LayoutOrder=order local l=ok:FindFirstChildOfClass('UIListLayout')if l then l.HorizontalAlignment=
Enum.HorizontalAlignment.Center end panel.content:Connect(ok.Activated,done)end return Pins end function
__DARKLUA_BUNDLE_MODULES.H()local v=__DARKLUA_BUNDLE_MODULES.cache.H if not v then v={c=__modImpl()}
__DARKLUA_BUNDLE_MODULES.cache.H=v end return v.c end end do local function __modImpl()local Common=
__DARKLUA_BUNDLE_MODULES.w()local Controls=__DARKLUA_BUNDLE_MODULES.t()local Create=__DARKLUA_BUNDLE_MODULES.s()local
I18n=__DARKLUA_BUNDLE_MODULES.d()local Panel=__DARKLUA_BUNDLE_MODULES.z()local Rows=__DARKLUA_BUNDLE_MODULES.v()local
Theme=__DARKLUA_BUNDLE_MODULES.r()local C,F,S=Theme.C,Theme.F,Theme.SIZE local new,corner,pad,list=Create.new,Create.
corner,Create.pad,Create.list local Settings={}function Settings.build(panel,deps,openLog)panel.clear()local store,t=
deps.store,deps.t local body=panel.body local order=0 local function nextOrder()order+=1 return order end Rows.group(
body,t('st.lang'),nextOrder())local seg=new('Frame',{Name='Langs',BackgroundColor3=C.track,Size=UDim2.new(1,0,0,if Theme
.touch then 40 else 34),LayoutOrder=nextOrder(),Parent=body},{corner(S.radius),pad(3,3,3,3),list('x',3)})for i,code in
I18n.LANGS do local on=deps.i18n.lang==code local b=new('TextButton',{Text=string.upper(code),AutoButtonColor=false,
BackgroundColor3=C.accent,BackgroundTransparency=if on then 0 else 1,Size=UDim2.new(1/#I18n.LANGS,-3,1,0),TextSize=12,
FontFace=F.mono,TextColor3=if on then C.white else C.text2,LayoutOrder=i,AutoLocalize=false,Parent=seg},{corner(6)})
panel.content:Connect(b.Activated,function()deps.setLang(code)end)end local function row(label)local r=Panel.row(body,
nextOrder(),if Theme.touch then S.rowTouch else 36)Create.text({text=label,size=13,auto=true},{LayoutOrder=1,Parent=r})
Panel.spacer(r,2)local right=new('Frame',{BackgroundTransparency=1,AutomaticSize=Enum.AutomaticSize.X,Size=UDim2.
fromScale(0,1),LayoutOrder=3,Parent=r},{list('x',6)})return r,right end if not Theme.touch then Rows.group(body,t(
'st.keys'),nextOrder())for _,field in{{'st.bar_key','paletteKey'},{'st.hide_key','toggleKey'}}do local r,right=row(t(
field[1]))local cap=Controls.kbd(right,(store.data)[field[2] ])panel.content:Connect(r.Activated,function()cap.Text=t(
'ui.press_key')deps.capture(function(k)if k~=Enum.KeyCode.Escape then(store.data)[field[2] ]=k.Name store:Save(field[2])
end cap.Text=(store.data)[field[2] ]end)end)end end Rows.group(body,t('st.behavior'),nextOrder())for _,field in{{
'st.chat','chatCommands'},{'st.sound','sound'}}do local r,right=row(t(field[1]))local sw=Controls.switch(right)sw.set((
store.data)[field[2] ]==true)panel.content:Connect(r.Activated,function()local v=not(store.data)[field[2] ];(store.data)
[field[2] ]=v store:Save(field[2])sw.set(v)end)end local logRow,logRight=row(t('st.log'))local errors=0 for _,e in deps.
log:Entries()do if e.level=='error'then errors+=1 end end if errors>0 then Create.text({text=t('st.errors',errors),size=
10.5,font=F.mono,color=C.accent,auto=true},{LayoutOrder=1,Parent=logRight})end Controls.glyph('arrow-right',logRight,14,
C.text3).LayoutOrder=2 panel.content:Connect(logRow.Activated,openLog)local off=Controls.button(body,t('st.unload'),
'danger','log-out')off.AutomaticSize=Enum.AutomaticSize.None off.Size=UDim2.new(1,0,0,if Theme.touch then 40 else 34)off
.LayoutOrder=nextOrder()local l=off:FindFirstChildOfClass('UIListLayout')if l then l.HorizontalAlignment=Enum.
HorizontalAlignment.Center end panel.content:Connect(off.Activated,deps.unload)Create.text({text=deps.info(),size=10,
font=F.mono,color=C.text3},{Size=UDim2.fromScale(1,0),AutomaticSize=Enum.AutomaticSize.Y,TextWrapped=true,TextTruncate=
Enum.TextTruncate.None,LayoutOrder=nextOrder(),Parent=body})end return Settings end function __DARKLUA_BUNDLE_MODULES.I(
)local v=__DARKLUA_BUNDLE_MODULES.cache.I if not v then v={c=__modImpl()}__DARKLUA_BUNDLE_MODULES.cache.I=v end return v
.c end end do local function __modImpl()local Analyze=__DARKLUA_BUNDLE_MODULES.p()local Controls=
__DARKLUA_BUNDLE_MODULES.t()local Create=__DARKLUA_BUNDLE_MODULES.s()local Format=__DARKLUA_BUNDLE_MODULES.i()local
Janitor=__DARKLUA_BUNDLE_MODULES.j()local Rows=__DARKLUA_BUNDLE_MODULES.v()local Theme=__DARKLUA_BUNDLE_MODULES.r()local
Types=__DARKLUA_BUNDLE_MODULES.c()local C,F=Theme.C,Theme.F local new,list=Create.new,Create.list local Detail={}local 
function wrap(parent,text,size,color,order)return Create.text({text=Create.marked(text,nil),size=size,color=color},{Size
=UDim2.fromScale(1,0),AutomaticSize=Enum.AutomaticSize.Y,TextWrapped=true,TextTruncate=Enum.TextTruncate.None,
LayoutOrder=order,Parent=parent})end local function kv(parent,key,order)local r=new('Frame',{Name='Row',
BackgroundTransparency=1,Size=UDim2.new(1,0,0,24),LayoutOrder=order,Parent=parent})Create.text({text=key,size=12,color=C
.text3},{Size=UDim2.fromScale(0.5,1),Parent=r})local right=new('Frame',{Name='Right',BackgroundTransparency=1,
AnchorPoint=Vector2.new(1,0),Position=UDim2.fromScale(1,0),Size=UDim2.fromScale(0.6,1),Parent=r})local l=list('x',6)l.
HorizontalAlignment=Enum.HorizontalAlignment.Right l.Parent=right return right end local function runButton(parent,text,
hooks,jan,order)local b=Controls.button(parent,text,'accent')b.AutomaticSize=Enum.AutomaticSize.None b.Size=UDim2.new(1,
0,0,34)b.LayoutOrder=order local l=b:FindFirstChildOfClass('UIListLayout')if l then l.HorizontalAlignment=Enum.
HorizontalAlignment.Center end Controls.kbd(b,'Enter').LayoutOrder=3 jan:Connect(b.Activated,hooks.accept)end function
Detail.home(frame,deps)local t=deps.t Create.text({text=t('sp.home_title'),size=18,font=F.medium},{Size=UDim2.new(1,0,0,
24),LayoutOrder=1,Parent=frame})wrap(frame,t('sp.home_text'),12,C.text3,2)local tips=new('Frame',{BackgroundTransparency
=1,Size=UDim2.fromScale(1,0),AutomaticSize=Enum.AutomaticSize.Y,LayoutOrder=3,Parent=frame},{list('y',6)})for i,tip in{
'fly','speed 50','help'}do local r=new('Frame',{BackgroundTransparency=1,Size=UDim2.new(1,0,0,22),LayoutOrder=i,Parent=
tips})Controls.kbd(r,tip)end end function Detail.command(frame,spec,deps,jan,hooks)local t,reg,store=deps.t,deps.
registry,deps.store local name=spec.name local refreshers={}Create.text({text=t('c.'..name),size=18,font=F.medium},{Size
=UDim2.new(1,0,0,24),LayoutOrder=1,Parent=frame})Create.text({text=Create.marked(Format.signature(spec),nil),size=12,
font=F.mono,color=C.text2},{Size=UDim2.new(1,0,0,16),LayoutOrder=2,Parent=frame})wrap(frame,t('d.'..name),12,C.text3,3)
local missing=reg:Missing(spec)if missing then wrap(frame,t('err.needs',name,missing),12,C.accent,4)return refreshers
end local req=Format.requiredArg(spec)if spec.kind=='value'then local holder=new('Frame',{BackgroundTransparency=1,Size=
UDim2.new(1,0,0,40),LayoutOrder=4,Parent=frame})local ctl=Rows.control(spec,holder,deps,jan,40,nil)table.insert(
refreshers,ctl.refresh)elseif spec.kind=='toggle'and not req then local right=kv(frame,t('sp.state_on'),4)local sw=new(
'TextButton',{Text='',AutoButtonColor=false,BackgroundTransparency=1,Size=UDim2.fromOffset(32,18),Parent=right})local
ctl=Rows.control(spec,sw,deps,jan,18,nil)table.insert(refreshers,ctl.refresh)jan:Connect(sw.Activated,function()deps.
run(name)end)elseif req then wrap(frame,t('sp.choose_arg',Format.argLabel(req)),12,C.text2,4)else runButton(frame,t(
'sp.run'),hooks,jan,4)end local keyRight=kv(frame,t('sp.key'),5)local key=Rows.keyFor(store,name)local cap=Controls.kbd(
keyRight,key or t('sp.no_key'))local capBtn=new('TextButton',{Text='',BackgroundTransparency=1,Size=UDim2.fromScale(1,1)
,Parent=cap})jan:Connect(capBtn.Activated,function()cap.Text=t('ui.press_key')deps.capture(function(k)local binds=store.
data.binds for bk,line in binds do if line==name then binds[bk]=nil end end if k~=Enum.KeyCode.Backspace and k~=Enum.
KeyCode.Escape then binds[k.Name]=name end store:Save('binds')cap.Text=Rows.keyFor(store,name)or t('sp.no_key')end)end)
if not req then local pinRight=kv(frame,t('sp.dock'),6)local star=new('TextButton',{Text='',AutoButtonColor=false,
BackgroundTransparency=1,Size=UDim2.fromOffset(22,22),Parent=pinRight})local g=Controls.glyph('star',star,16,if deps.
isPinned(name)then C.accent else C.text3)g.AnchorPoint=Vector2.new(0.5,0.5)g.Position=UDim2.fromScale(0.5,0.5)jan:
Connect(star.Activated,function()deps.togglePin(name)Controls.tint(g,if deps.isPinned(name)then C.accent else C.text3)
end)end if spec.aliases and#spec.aliases>0 then local r=kv(frame,t('sp.also'),7)Create.text({text=table.concat(spec.
aliases,' \u{b7} '),size=11,font=F.mono,color=C.text2,auto=true},{Parent=r})end return refreshers end function Detail.
player(frame,item,spec,deps,jan,hooks)local t=deps.t local p=item.player local who=new('Frame',{BackgroundTransparency=1
,Size=UDim2.new(1,0,0,48),LayoutOrder=1,Parent=frame})Controls.avatar(who,p.UserId,48)Create.text({text=Create.marked(p.
DisplayName,nil),size=18,font=F.medium},{Position=UDim2.fromOffset(60,4),Size=UDim2.new(1,-60,0,22),Parent=who})Create.
text({text='@'..p.Name..' \u{b7} '..p.UserId,size=10.5,font=F.mono,color=C.text3},{Position=UDim2.fromOffset(60,28),Size
=UDim2.new(1,-60,0,14),Parent=who})local age=kv(frame,t('sp.account'),2)Create.text({text=t('sp.days',p.AccountAge),size
=12,font=F.mono,auto=true},{Parent=age})local team=kv(frame,t('sp.team'),3)Create.text({text=if p.Team then p.Team.Name
else'\u{2014}',size=12,font=F.mono,auto=true},{Parent=team})if spec then runButton(frame,t('c.'..spec.name),hooks,jan,4)
end end function Detail.value(frame,item,spec,deps,jan,hooks)Create.text({text=Create.marked(item.label,nil),size=18,
font=F.medium},{Size=UDim2.new(1,0,0,24),LayoutOrder=1,Parent=frame})if spec then wrap(frame,deps.t('d.'..spec.name),12,
C.text3,2)runButton(frame,deps.t('c.'..spec.name),hooks,jan,3)end end return Detail end function
__DARKLUA_BUNDLE_MODULES.J()local v=__DARKLUA_BUNDLE_MODULES.cache.J if not v then v={c=__modImpl()}
__DARKLUA_BUNDLE_MODULES.cache.J=v end return v.c end end do local function __modImpl()local Analyze=
__DARKLUA_BUNDLE_MODULES.p()local Controls=__DARKLUA_BUNDLE_MODULES.t()local Create=__DARKLUA_BUNDLE_MODULES.s()local
Format=__DARKLUA_BUNDLE_MODULES.i()local Janitor=__DARKLUA_BUNDLE_MODULES.j()local Rows=__DARKLUA_BUNDLE_MODULES.v()
local Theme=__DARKLUA_BUNDLE_MODULES.r()local Types=__DARKLUA_BUNDLE_MODULES.c()local C,F,S=Theme.C,Theme.F,Theme.SIZE
local new,corner,pad,list=Create.new,Create.corner,Create.pad,Create.list local Touch={}local H=S.rowTouch local 
function flow(parent,order)local f=new('Frame',{Name='Flow',BackgroundTransparency=1,Size=UDim2.fromScale(1,0),
AutomaticSize=Enum.AutomaticSize.Y,LayoutOrder=order,Parent=parent})new('UIListLayout',{FillDirection=Enum.FillDirection
.Horizontal,Wraps=true,Padding=UDim.new(0,6),SortOrder=Enum.SortOrder.LayoutOrder,Parent=f})return f end local function 
grid(parent,order,cols,count,cellH)local cells={}local rowsN=math.ceil(count/cols)local holder=new('Frame',{Name='Grid',
BackgroundTransparency=1,Size=UDim2.new(1,0,0,rowsN*cellH+(rowsN-1)*6),LayoutOrder=order,Parent=parent},{list('y',6)})
for r=1,rowsN do local row=new('Frame',{BackgroundTransparency=1,Size=UDim2.new(1,0,0,cellH),LayoutOrder=r,Parent=holder
},{list('x',6)})for c=1,cols do if(r-1)*cols+c>count then break end local cell=new('Frame',{BackgroundTransparency=1,
Size=UDim2.new(1/cols,-6*(cols-1)/cols,1,0),LayoutOrder=c,Parent=row})table.insert(cells,cell)end end return cells end
local function tapCard(parent,on)return new('TextButton',{Text='',AutoButtonColor=false,BackgroundColor3=if on then C.
accent else C.track,Size=UDim2.fromScale(1,1),Parent=parent},{corner(S.radius),pad(10,10)})end local function commandRow
(parent,spec,deps,jan,hooks,order,scroll)local name=spec.name local a1=spec.args and spec.args[1]if spec.kind=='value'
and a1 and a1.kind=='number'then local holder=new('Frame',{BackgroundTransparency=1,Size=UDim2.new(1,0,0,H),LayoutOrder=
order,Parent=parent})local ctl=Rows.control(spec,holder,deps,jan,H,scroll)table.insert(hooks.refreshers,ctl.refresh)
return end local row=new('TextButton',{Name='Row',Text='',AutoButtonColor=false,BackgroundColor3=C.track,Size=UDim2.new(
1,0,0,H),LayoutOrder=order,Parent=parent},{corner(S.radius),pad(12,10)})local texts=new('Frame',{BackgroundTransparency=
1,Size=UDim2.new(1,-50,1,0),Parent=row},{list('x',8)})Create.text({text=deps.t('c.'..name),size=14,font=F.medium,auto=
true},{LayoutOrder=1,Parent=texts})Create.text({text=name,size=10.5,font=F.mono,color=C.text3,auto=true},{LayoutOrder=2,
Parent=texts})local right=new('Frame',{BackgroundTransparency=1,AnchorPoint=Vector2.new(1,0.5),Position=UDim2.fromScale(
1,0.5),Size=UDim2.fromOffset(32,18),Parent=row})local ctl=Rows.control(spec,right,deps,jan,18,nil)table.insert(hooks.
refreshers,ctl.refresh)local req=Format.requiredArg(spec)jan:Connect(row.Activated,function()if req then hooks.setLine(
name..' ',req.kind=='string'or req.kind=='rest'or req.kind=='number')else deps.run(name)end end)end function Touch.home(
body,groups,deps,jan,hooks)local order=0 local function nextOrder()order+=1 return order end for _,g in groups do if g.
title then Rows.group(body,g.title,nextOrder())end local isRecent=g.items[1]and g.items[1].kind=='line'if isRecent then
local f=flow(body,nextOrder())for i,item in g.items do local on=not item.group and item.spec and deps.registry:IsActive(
(item.spec).name)local chip=new('TextButton',{Text='',AutoButtonColor=false,AutomaticSize=Enum.AutomaticSize.X,Size=
UDim2.fromOffset(0,38),BackgroundColor3=if on then Color3.fromHex('3b1a1d')else C.control,LayoutOrder=i,Parent=f},{
corner(S.radius),pad(12,12),list('x',6)})if on then new('Frame',{Size=UDim2.fromOffset(6,6),BackgroundColor3=C.accent,
LayoutOrder=1,Parent=chip},{corner(3)})end Create.text({text=Create.marked(item.label,nil),size=12.5,font=if item.group
then F.medium else F.mono,auto=true},{LayoutOrder=2,Parent=chip})jan:Connect(chip.Activated,function()deps.run(item.text
)end)end else local cells=grid(body,nextOrder(),4,#g.items,52)for i,item in g.items do local spec=item.spec local on=
deps.registry:IsActive(spec.name)local card=tapCard(cells[i],on)local l=list('x',8)l.Parent=card Controls.glyph(spec.
icon or'command',card,16,if on then C.white else C.text2).LayoutOrder=1 Create.text({text=deps.t('c.'..spec.name),size=
13,font=F.medium,color=if on then C.white else C.text1},{Size=UDim2.new(1,-24,1,0),LayoutOrder=2,Parent=card})jan:
Connect(card.Activated,function()hooks.quick(spec)end)end end end local all=new('TextButton',{Name='All',Text='',
AutoButtonColor=false,BackgroundTransparency=1,Size=UDim2.new(1,0,0,34),LayoutOrder=nextOrder(),Parent=body},{pad(4,4)})
Create.text({text=deps.t('sp.all'),size=13,font=F.medium,color=C.text2},{Size=UDim2.new(1,-20,1,0),Parent=all})local
chev=Controls.glyph('arrow-right',all,14,C.text3)chev.AnchorPoint=Vector2.new(1,0.5)chev.Position=UDim2.fromScale(1,0.5)
jan:Connect(all.Activated,function()deps.openPanel('commands')end)end function Touch.commands(body,groups,deps,jan,hooks
,scroll)local order=0 for _,g in groups do for _,item in g.items do order+=1 if item.kind=='line'then local row=new(
'TextButton',{Name='Row',Text='',AutoButtonColor=false,BackgroundColor3=C.track,Size=UDim2.new(1,0,0,H),LayoutOrder=
order,Parent=body},{corner(S.radius),pad(12,10),list('x',8)})local icon=item.spec and(item.spec).icon or'box'Controls.
glyph(icon,row,16,C.text2).LayoutOrder=1 Create.text({text=Create.marked(item.label,nil),size=14,font=F.medium,auto=true
},{LayoutOrder=2,Parent=row})if item.sub then Create.text({text=Create.marked(item.sub,nil),size=11,color=C.text3,auto=
true},{LayoutOrder=3,Parent=row})end jan:Connect(row.Activated,function()deps.run(item.text)end)elseif item.spec then
commandRow(body,item.spec,deps,jan,hooks,order,scroll)end end end end function Touch.args(body,a,groups,deps,jan,hooks,
text)local spec=a.spec local head=new('Frame',{BackgroundTransparency=1,Size=UDim2.new(1,0,0,22),LayoutOrder=1,Parent=
body},{list('x',8)})Create.text({text=deps.t('c.'..spec.name),size=14,font=F.medium,auto=true},{LayoutOrder=1,Parent=
head})Create.text({text=Create.marked(Format.signature(spec,a.argIndex,true),nil),size=10.5,font=F.mono,color=C.text3,
auto=true},{LayoutOrder=2,Parent=head})local items=groups[1]and groups[1].items or{}if#items==0 then Create.text({text=
deps.t('ui.nothing'),size=13,color=C.text3},{Size=UDim2.new(1,0,0,30),LayoutOrder=2,Parent=body})return end local pick=
function(item)local line,ready=Analyze.accept(text,a,item)if ready then deps.run(line)hooks.setLine('')else hooks.
setLine(line)end end if items[1].kind=='player'then local cells=grid(body,2,3,#items,52)for i,item in items do local p=
item.player local card=tapCard(cells[i],false)local av=Controls.avatar(card,p.UserId,30)av.AnchorPoint=Vector2.new(0,0.5
)av.Position=UDim2.fromScale(0,0.5)Create.text({text=Create.marked(p.DisplayName,item.marks),size=13,font=F.medium},{
Position=UDim2.fromOffset(38,7),Size=UDim2.new(1,-38,0,18),Parent=card})Create.text({text=Create.marked('@'..p.Name,item
.subMarks),size=10,font=F.mono,color=C.text3},{Position=UDim2.fromOffset(38,26),Size=UDim2.new(1,-38,0,14),Parent=card})
jan:Connect(card.Activated,function()pick(item)end)end else local f=flow(body,2)for i,item in items do local chip=new(
'TextButton',{Text='',AutoButtonColor=false,AutomaticSize=Enum.AutomaticSize.X,Size=UDim2.fromOffset(0,40),
BackgroundColor3=C.control,LayoutOrder=i,Parent=f},{corner(S.radius),pad(14,14)})Create.text({text=Create.marked(item.
label,item.marks),size=13,auto=true},{Parent=chip})jan:Connect(chip.Activated,function()pick(item)end)end end end return
Touch end function __DARKLUA_BUNDLE_MODULES.K()local v=__DARKLUA_BUNDLE_MODULES.cache.K if not v then v={c=__modImpl()}
__DARKLUA_BUNDLE_MODULES.cache.K=v end return v.c end end do local function __modImpl()local UserInputService=game:
GetService('UserInputService')local Analyze=__DARKLUA_BUNDLE_MODULES.p()local Controls=__DARKLUA_BUNDLE_MODULES.t()local
Create=__DARKLUA_BUNDLE_MODULES.s()local Detail=__DARKLUA_BUNDLE_MODULES.J()local Format=__DARKLUA_BUNDLE_MODULES.i()
local Janitor=__DARKLUA_BUNDLE_MODULES.j()local Rows=__DARKLUA_BUNDLE_MODULES.v()local Theme=__DARKLUA_BUNDLE_MODULES.r(
)local Touch=__DARKLUA_BUNDLE_MODULES.K()local Types=__DARKLUA_BUNDLE_MODULES.c()local C,F,LINE,S=Theme.C,Theme.F,Theme.
LINE,Theme.SIZE local new,corner,pad,list=Create.new,Create.corner,Create.pad,Create.list local Spotlight={}local
MAX_DESKTOP=330 function Spotlight.new(layer,jan,deps)local touch=Theme.touch local t,reg,store=deps.t,deps.registry,
deps.store local W=if touch then S.barTouch else S.bar local LEFT=S.results local root=new('Frame',{Name='Spotlight',
AnchorPoint=Vector2.new(0.5,0),Position=UDim2.new(0.5,0,0,if touch then 8 else S.barTop),Size=UDim2.fromOffset(W,0),
AutomaticSize=Enum.AutomaticSize.Y,BackgroundColor3=C.surface,Visible=false,Active=true,Parent=layer},{corner(if touch
then S.card else S.window),Create.stroke(LINE.strong),list('y',0)})Create.shadow(root,Theme.SHADOW.window)local stats=
nil if not touch then local head=new('Frame',{Name='Head',BackgroundTransparency=1,Size=UDim2.new(1,0,0,30),LayoutOrder=
1,Parent=root},{pad(16,14,10,0)})local hl=new('Frame',{BackgroundTransparency=1,Size=UDim2.fromScale(0.6,1),Parent=head}
,{list('x',8)})Controls.logo(hl,13).LayoutOrder=1 Controls.eyebrow(hl,t('sp.title')).LayoutOrder=2 stats=Create.text({
text='',size=10,font=F.mono,color=C.text3,x=Enum.TextXAlignment.Right},{AnchorPoint=Vector2.new(1,0),Position=UDim2.
fromScale(1,0),Size=UDim2.fromScale(0.4,1),Parent=head})end local inputRow=new('Frame',{Name='InputRow',
BackgroundTransparency=1,Size=UDim2.new(1,0,0,if touch then 50 else 46),LayoutOrder=2,Parent=root},{pad(if touch then 12
else 16,if touch then 8 else 14)})local lead=new('Frame',{BackgroundTransparency=1,AnchorPoint=Vector2.new(0,0.5),
Position=UDim2.fromScale(0,0.5),Size=UDim2.fromOffset(18,18),Parent=inputRow})if touch then Controls.logo(lead,16)else
Controls.glyph('search',lead,16,C.text2)end local textSize=if touch then 15 else 18 local ghost=Create.text({text='',
size=textSize,font=F.medium,color=C.text3},{Name='Ghost',Position=UDim2.fromOffset(28,0),Size=UDim2.new(1,-90,1,0),
TextTruncate=Enum.TextTruncate.None,ClipsDescendants=true,Parent=inputRow})local input=new('TextBox',{Name='Input',
BackgroundTransparency=1,Position=UDim2.fromOffset(28,0),Size=UDim2.new(1,-90,1,0),Text='',PlaceholderText=t('ui.search'
),PlaceholderColor3=C.text3,TextColor3=C.text1,TextSize=textSize,FontFace=F.medium,TextXAlignment=Enum.TextXAlignment.
Left,ClearTextOnFocus=false,AutoLocalize=false,ClipsDescendants=true,Parent=inputRow})local rightSlot=new('Frame',{
BackgroundTransparency=1,AnchorPoint=Vector2.new(1,0.5),Position=UDim2.fromScale(1,0.5),Size=UDim2.fromOffset(60,34),
Parent=inputRow})local rl=list('x',6)rl.HorizontalAlignment=Enum.HorizontalAlignment.Right rl.Parent=rightSlot local
keyCap=nil local closeBtn=nil if touch then closeBtn=Controls.iconButton(rightSlot,'x',34,true)else keyCap=Controls.kbd(
rightSlot,'Esc')end local sigRow=new('Frame',{Name='Signature',BackgroundTransparency=1,Size=UDim2.new(1,0,0,24),
LayoutOrder=3,Visible=false,Parent=root},{pad(if touch then 12 else 16,16,0,6),list('x',6)})local sigCmd=Create.text({
text='',size=12,font=F.mono,color=C.text2,auto=true},{LayoutOrder=1,Parent=sigRow})local sigArg=Create.text({text='',
size=12,font=F.mono,color=C.accent,auto=true},{LayoutOrder=2,BackgroundTransparency=0.84,BackgroundColor3=C.accent,
Parent=sigRow})corner(4).Parent=sigArg pad(6,6).Parent=sigArg local sigDesc=Create.text({text='',size=12,color=C.text3},
{LayoutOrder=3,Size=UDim2.new(1,-200,1,0),Parent=sigRow})Controls.hairline(root,4)local body=new('Frame',{Name='Body',
BackgroundTransparency=1,Size=UDim2.fromScale(1,0),AutomaticSize=Enum.AutomaticSize.Y,LayoutOrder=5,Parent=root})local
results=new('ScrollingFrame',{Name='Results',BackgroundTransparency=1,BorderSizePixel=0,Size=UDim2.new(if touch then 1
else 0,if touch then 0 else LEFT,0,0),CanvasSize=UDim2.fromScale(0,0),AutomaticCanvasSize=Enum.AutomaticSize.Y,
ScrollingDirection=Enum.ScrollingDirection.Y,ScrollBarThickness=3,ScrollBarImageColor3=C.text3,Parent=body},{pad(8,8,8,
10),list('y',if touch then 6 else 2)})local resultsMax=MAX_DESKTOP local refitResults=Create.fitScroll(results,function(
)return resultsMax end)local detail=nil if not touch then new('UISizeConstraint',{MinSize=Vector2.new(0,210),Parent=body
})new('Frame',{Name='Divider',BackgroundColor3=C.white,BackgroundTransparency=LINE.default,BorderSizePixel=0,Position=
UDim2.fromOffset(LEFT,0),Size=UDim2.new(0,1,1,0),Parent=body})detail=new('Frame',{Name='Detail',BackgroundTransparency=1
,Position=UDim2.fromOffset(LEFT+1,0),Size=UDim2.new(1,-LEFT-1,1,0),ClipsDescendants=true,Parent=body},{pad(16,16,14,14),
list('y',10)})end Controls.hairline(root,6)local foot=new('Frame',{Name='Foot',BackgroundTransparency=1,Size=UDim2.new(1
,0,0,if touch then 52 else 30),LayoutOrder=7,Parent=root},{pad(if touch then 8 else 16,if touch then 8 else 16,if touch
then 6 else 0,if touch then 6 else 0)})local panelButtons={}if touch then list('x',6).Parent=foot for i,entry in{{
'commands','list'},{'binds','key'},{'settings','settings'}}do local b=Controls.button(foot,t('pn.'..entry[1]),'plain',
entry[2])b.AutomaticSize=Enum.AutomaticSize.None b.Size=UDim2.new(1/3,-4,1,0)b.LayoutOrder=i local l=b:
FindFirstChildOfClass('UIListLayout')if l then l.HorizontalAlignment=Enum.HorizontalAlignment.Center end panelButtons[
entry[1] ]=b end else local hints=new('Frame',{BackgroundTransparency=1,Size=UDim2.fromScale(0.8,1),Parent=foot},{list(
'x',14)})for i,h in{{'\u{2191}\u{2193}','sp.k_select'},{'Tab','sp.k_complete'},{'Enter','sp.k_run'}}do Create.text({text
=h[1]..'  '..t(h[2]),size=10,font=F.mono,color=C.text3,auto=true},{LayoutOrder=i,Parent=hints})end Create.text({text=
'Esc  '..t('sp.k_close'),size=10,font=F.mono,color=C.text3,x=Enum.TextXAlignment.Right},{AnchorPoint=Vector2.new(1,0),
Position=UDim2.fromScale(1,0),Size=UDim2.fromScale(0.3,1),Parent=foot})end local text=''local analysis=Analyze.line('',
reg)local flat={}local buttons={}local sel=1 local historyAt=0 local suppress=false local isOpen=false local renderJan=
Janitor.new()local detailJan=Janitor.new()jan:Add(renderJan)jan:Add(detailJan)local refreshers={}local function clear(
frame)for _,c in frame:GetChildren()do if c:IsA('GuiObject')then c:Destroy()end end end local function fitHeight()local
cam=workspace.CurrentCamera local vpY=if cam then cam.ViewportSize.Y else 720 local top=root.Position.Y.Offset local
fixed=if touch then 50+52+26 else 30+46+30+26 resultsMax=math.max(120,math.min(MAX_DESKTOP,vpY-top-fixed-16))
refitResults()end local setText local accept local function hooksDetail()return{accept=function()accept(true)end}end
local function renderDetail()local d=detail if not d then return end detailJan:Cleanup()clear(d)local item=flat[sel]if
analysis.mode=='home'and not item then Detail.home(d,deps)return end if not item then local spec=analysis.spec if spec
then for _,r in Detail.command(d,spec,deps,detailJan,hooksDetail())do table.insert(refreshers,r)end end return end if
item.kind=='player'then Detail.player(d,item,analysis.spec,deps,detailJan,hooksDetail())elseif item.kind=='value'then
Detail.value(d,item,analysis.spec,deps,detailJan,hooksDetail())elseif item.spec then for _,r in Detail.command(d,item.
spec,deps,detailJan,hooksDetail())do table.insert(refreshers,r)end end end local function paintSelection()for i,b in
buttons do b.BackgroundTransparency=if i==sel then 0 else 1 local desc=b:FindFirstChild('Desc')if desc and desc:IsA(
'TextLabel')then desc.TextColor3=if i==sel then C.text2 else C.text3 end end renderDetail()end local function setGhost(
completion)if completion and#completion>#text and string.lower(string.sub(completion,1,#text))==string.lower(text)then
ghost.Text='<font transparency="1">'..Create.marked(text,nil)..'</font>'..Create.marked(string.sub(completion,#text+1),
nil)else ghost.Text=''end end local function render()renderJan:Cleanup()clear(results)table.clear(refreshers)table.
clear(flat)table.clear(buttons)analysis=Analyze.line(text,reg)local mode=analysis.mode local groups if mode=='home'then
groups=Analyze.home(reg,store.data.history,store.data.pins,t,deps.modules)elseif mode=='command'then groups=Analyze.
commands(analysis.query,reg,t,Analyze.modules(analysis.query,deps.modules,reg,t))elseif mode=='args'then groups=Analyze.
suggestions(analysis,reg,t)else groups={}end for _,g in groups do for _,item in g.items do table.insert(flat,item)end
end sel=math.clamp(sel,1,math.max(#flat,1))local spec=analysis.spec if mode=='args'and spec then sigRow.Visible=true
sigCmd.Text=spec.name local arg=analysis.arg sigArg.Visible=arg~=nil sigArg.Text=if arg then Create.marked(Format.
argLabel(arg),nil)else''sigDesc.Text=' \u{b7} '..t('d.'..spec.name)else sigRow.Visible=false end if mode=='command'then
setGhost(flat[1]and flat[1].text)elseif mode=='args'and flat[1]then setGhost(string.sub(text,1,#text-#analysis.query)..
flat[1].text)else ghost.Text=''end if keyCap then keyCap.Text=if mode=='home'then'Esc'else'Tab'end if stats then stats.
Text=t('sp.stats',#reg.specs,reg:ActiveCount())end if touch then local th={setLine=function(line,keyboard)setText(line,
keyboard)end,quick=deps.quick,refreshers=refreshers}if mode=='home'then Touch.home(results,groups,deps,renderJan,th)
elseif mode=='command'then Touch.commands(results,groups,deps,renderJan,th,results)elseif mode=='args'then Touch.args(
results,analysis,groups,deps,renderJan,th,text)else Create.text({text=t('err.unknown',analysis.query),size=13,color=C.
text3},{Size=UDim2.new(1,0,0,32),Parent=results})end return end local order=0 for _,g in groups do if g.title then order
+=1 Rows.group(results,g.title,order)end for _,item in g.items do order+=1 local index=#buttons+1 local b if item.kind==
'player'then b=Rows.player(results,item,index==sel,order)elseif item.kind=='value'then b=Rows.value(results,item,index==
sel,order)elseif item.kind=='line'then b=Rows.line(results,item,index==sel,deps,order)else b=Rows.command(results,item,
index==sel,deps,order)end table.insert(buttons,b)renderJan:Connect(b.MouseEnter,function()if sel~=index then sel=index
paintSelection()end end)renderJan:Connect(b.Activated,function()sel=index accept(true)end)end end if#flat==0 and mode~=
'home'then Create.text({text=if mode=='unknown'then t('err.unknown',analysis.query)else t('ui.nothing'),size=13,color=C.
text3},{Size=UDim2.new(1,0,0,30),LayoutOrder=999,Parent=results})end renderDetail()end setText=function(line,keyboard)
suppress=true text=line input.Text=line input.CursorPosition=#line+1 suppress=false sel=1 render()if keyboard or(not
touch and isOpen)then input:CaptureFocus()input.CursorPosition=#line+1 end end local function close()if not isOpen then
return end isOpen=false root.Visible=false input:ReleaseFocus()historyAt=0 suppress=true text=''input.Text=''suppress=
false end accept=function(runIt)local item=flat[sel]local line,ready=Analyze.accept(text,analysis,item)if analysis.mode
=='home'and not item then close()return end if ready and runIt and string.match(line,'%S')then deps.run(line)if touch
then setText('')else close()end else setText(line,true)end end jan:Connect(input:GetPropertyChangedSignal('Text'),
function()if suppress then return end local v=input.Text if string.find(v,'\t',1,true)then setText((string.gsub(v,'\t',
'')))return end text=v historyAt=0 sel=1 render()end)jan:Connect(input.FocusLost,function(enter)if enter and isOpen then
accept(true)end end)jan:Connect(UserInputService.InputBegan,function(io)if not isOpen then return end local key=io.
KeyCode if key==Enum.KeyCode.Escape then task.defer(close)return end if not input:IsFocused()then return end if key==
Enum.KeyCode.Tab then local item=flat[sel]local line=Analyze.accept(text,analysis,item)task.defer(setText,line,true)
elseif key==Enum.KeyCode.Down or key==Enum.KeyCode.Up then local hist=store.data.history if text==''or historyAt>0 then
if#hist==0 then return end historyAt=if key==Enum.KeyCode.Up then math.min(historyAt+1,#hist)else math.max(historyAt-1,0
)local at=historyAt task.defer(function()setText(if at>0 then hist[#hist-at+1]else'')historyAt=at end)elseif#flat>0 then
sel=if key==Enum.KeyCode.Down then sel%#flat+1 else(sel-2)%#flat+1 paintSelection()end end end)if closeBtn then jan:
Connect(closeBtn.Activated,close)end for id,b in panelButtons do jan:Connect(b.Activated,function()deps.openPanel(id)end
)end return{frame=root,input=input,open=function(prefill)isOpen=true root.Visible=true fitHeight()local needsKeyboard=
not touch or(prefill~=nil and prefill~='')setText(prefill or'',needsKeyboard)end,close=close,isOpen=function()return
isOpen end,refresh=function()if not isOpen then return end local pos=results.CanvasPosition local keepSel=sel render()
sel=math.clamp(keepSel,1,math.max(#flat,1))if not touch then paintSelection()end results.CanvasPosition=pos end,text=
function()return text end}end return Spotlight end function __DARKLUA_BUNDLE_MODULES.L()local v=__DARKLUA_BUNDLE_MODULES
.cache.L if not v then v={c=__modImpl()}__DARKLUA_BUNDLE_MODULES.cache.L=v end return v.c end end do local function 
__modImpl()local SoundService=game:GetService('SoundService')local Assets=__DARKLUA_BUNDLE_MODULES.q()local Create=
__DARKLUA_BUNDLE_MODULES.s()local Store=__DARKLUA_BUNDLE_MODULES.l()local Theme=__DARKLUA_BUNDLE_MODULES.r()local Types=
__DARKLUA_BUNDLE_MODULES.c()local C,F,LINE,S=Theme.C,Theme.F,Theme.LINE,Theme.SIZE local new,corner,pad,list,tween=
Create.new,Create.corner,Create.pad,Create.list,Create.tween local MAX=3 local LIFE=3 local LIFE_ERROR=5 local LIFE_NOTE
=7 local PING='rbxasset://sounds/electronicpingshort.wav'local Toasts={}function Toasts.new(layer,store)local stack=new(
'Frame',{Name='Toasts',BackgroundTransparency=1,AnchorPoint=Vector2.new(0.5,1),Position=UDim2.new(0.5,0,1,-20),Size=
UDim2.fromOffset(420,200),Parent=layer})local l=list('y',6,Enum.VerticalAlignment.Bottom)l.HorizontalAlignment=Enum.
HorizontalAlignment.Center l.Parent=stack local order=0 local function fade(card,life)tween(card,{GroupTransparency=0})
task.delay(life,function()if card.Parent then tween(card,{GroupTransparency=1})task.wait(0.2)card:Destroy()end end)end
local function ping()if store.data.sound then local s=Instance.new('Sound')s.SoundId=PING s.Volume=0.35 pcall(
SoundService.PlayLocalSound,SoundService,s)task.delay(2,function()s:Destroy()end)end end local function show(kind,text)
order+=1 local items={}for _,c in stack:GetChildren()do if c:IsA('CanvasGroup')then table.insert(items,c)end end table.
sort(items,function(a,b)return a.LayoutOrder<b.LayoutOrder end)for i=1,#items-MAX+1 do items[i]:Destroy()end local card=
new('CanvasGroup',{Name='Toast',BackgroundColor3=C.surface,AutomaticSize=Enum.AutomaticSize.XY,Size=UDim2.fromOffset(0,0
),LayoutOrder=order,GroupTransparency=1,Parent=stack},{corner(10),Create.stroke(LINE.default),pad(12,14,7,7),list('x',8)
})new('Frame',{Size=UDim2.fromOffset(6,6),BackgroundColor3=if kind=='error'then C.accent elseif kind=='ok'then C.accent
else C.text2,LayoutOrder=1,Parent=card},{corner(3)})Create.text({text=Create.marked(text,nil),size=13,auto=true},{Size=
UDim2.fromOffset(0,18),TextWrapped=true,LayoutOrder=2,Parent=card})new('UISizeConstraint',{MaxSize=Vector2.new(420,80),
Parent=card})fade(card,if kind=='error'then LIFE_ERROR else LIFE)if kind=='error'then ping()end end local note=nil local 
function notify(title,text)if note then note:Destroy()end local card=new('CanvasGroup',{Name='Notification',AnchorPoint=
Vector2.new(1,1),Position=UDim2.new(1,-20,1,-20),BackgroundColor3=C.surface,AutomaticSize=Enum.AutomaticSize.XY,Size=
UDim2.fromOffset(0,0),GroupTransparency=1,Parent=layer},{corner(S.card),Create.stroke(LINE.strong),pad(10,14,10,10),
list('x',10)})note=card local teto=Assets.image('teto')if teto then new('ImageLabel',{Name='Teto',BackgroundTransparency
=1,Size=UDim2.fromOffset(40,40),Image=teto,ScaleType=Enum.ScaleType.Fit,LayoutOrder=1,Parent=card})end local col=new(
'Frame',{BackgroundTransparency=1,AutomaticSize=Enum.AutomaticSize.XY,Size=UDim2.fromOffset(0,0),LayoutOrder=2,Parent=
card},{list('y',2)})Create.text({text=Create.marked(title,nil),size=13,font=F.medium,auto=true},{Size=UDim2.fromOffset(0
,18),LayoutOrder=1,Parent=col})Create.text({text=Create.marked(text,nil),size=12,color=C.text2,auto=true},{Size=UDim2.
fromOffset(0,16),LayoutOrder=2,Parent=col})fade(card,LIFE_NOTE)ping()end return{show=show,notify=notify}end return
Toasts end function __DARKLUA_BUNDLE_MODULES.M()local v=__DARKLUA_BUNDLE_MODULES.cache.M if not v then v={c=__modImpl()}
__DARKLUA_BUNDLE_MODULES.cache.M=v end return v.c end end do local function __modImpl()local AvatarPanel=
__DARKLUA_BUNDLE_MODULES.y()local Binds=__DARKLUA_BUNDLE_MODULES.A()local Commands=__DARKLUA_BUNDLE_MODULES.B()local
Common=__DARKLUA_BUNDLE_MODULES.w()local Create=__DARKLUA_BUNDLE_MODULES.s()local Dock=__DARKLUA_BUNDLE_MODULES.C()local
EmoteWheel=__DARKLUA_BUNDLE_MODULES.D()local Format=__DARKLUA_BUNDLE_MODULES.i()local I18n=__DARKLUA_BUNDLE_MODULES.d()
local Janitor=__DARKLUA_BUNDLE_MODULES.j()local Launcher=__DARKLUA_BUNDLE_MODULES.E()local Log=__DARKLUA_BUNDLE_MODULES.
e()local LogPanel=__DARKLUA_BUNDLE_MODULES.F()local ModulePanel=__DARKLUA_BUNDLE_MODULES.G()local Modules=
__DARKLUA_BUNDLE_MODULES.o()local Panel=__DARKLUA_BUNDLE_MODULES.z()local Pins=__DARKLUA_BUNDLE_MODULES.H()local
Registry=__DARKLUA_BUNDLE_MODULES.n()local Settings=__DARKLUA_BUNDLE_MODULES.I()local Spotlight=__DARKLUA_BUNDLE_MODULES
.L()local Store=__DARKLUA_BUNDLE_MODULES.l()local Theme=__DARKLUA_BUNDLE_MODULES.r()local Toasts=
__DARKLUA_BUNDLE_MODULES.M()local Types=__DARKLUA_BUNDLE_MODULES.c()local new=Create.new local App={}function App.new(
deps)local reg,store,t=deps.registry,deps.store,deps.t local jan=Janitor.new()local uiJan=Janitor.new()jan:Add(uiJan)
local gui local layer local toasts local bar local dock local launcher local panels={}local modulePanels={}local avatar=
nil local wheel=nil local shown=true local function toast(kind,text)if toasts then toasts.show(kind,text)end end local 
function runLine(line)task.spawn(function()local ok,msg=deps.run(line)if not ok and msg then toast('error',msg)end end)
end local function isPinned(name)return table.find(store.data.pins,name)~=nil end local function togglePin(name)local
pins=store.data.pins local i=table.find(pins,name)if i then table.remove(pins,i)elseif#pins<Pins.MAX then table.insert(
pins,name)end store:Save('pins')if dock then dock.rebuild()end end local function setShown(v)shown=v if layer then layer
.Visible=v end if not v and bar then bar.close()end end local openBar local openPanel local closePanel local openModule
local openAvatar local function closeModules(except)for id,p in modulePanels do if id~=except then p.close()end end if
except~='avatar'and avatar then avatar.close()end end local function quick(spec)local name=spec.name local req=Format.
requiredArg(spec)if spec.kind=='value'then if reg:IsActive(name)then runLine('un'..name)return end local last=reg:Args(
name)[1]if last~=nil then runLine(name..' '..Format.value(last))elseif dock then dock.popover(spec)end elseif req then
openBar(name..' ')else runLine(name)end end local common local function panelDeps()return common end local builders={
commands=function(p)Commands.build(p,panelDeps())end,binds=function(p)Binds.build(p,panelDeps(),function()openPanel(
'binds')end)end,settings=function(p)Settings.build(p,panelDeps(),function()openPanel('log')end)end,log=function(p)
LogPanel.build(p,panelDeps())end,pins=function(p)Pins.build(p,panelDeps(),function()closePanel('pins')end)end}local 
function origin(id)return function(vp,w)if id=='commands'then return 40,150 elseif id=='pins'then return 16,132 elseif
id=='log'then return(vp.X-w)/2,140 end return vp.X-w-40,150 end end local function getPanel(id)local p=panels[id]if p
then return p end p=Panel.new(layer,uiJan,{id=id,title=t('pn.'..id),width=if id=='settings'or id=='binds'then 300 elseif
id=='log'then 420 else nil,store=store,origin=origin(id)})panels[id]=p return p end openPanel=function(id)if not shown
then setShown(true)end if Theme.touch then bar.close()closeModules(nil)for other,p in panels do if other~=id then p.
close()end end end local p=getPanel(id)builders[id](p)p.open()end closePanel=function(id)local p=panels[id]if p then p.
close()end end openBar=function(prefill)if not shown then setShown(true)end if Theme.touch then closeModules(nil)for _,p
in panels do p.close()end end bar.open(prefill)end openModule=function(id)local mods=deps.modules if id==''then local
first=mods:Available()[1]if not first then toast('info',t('md.none'))return end id=first.id end if not mods:Get(id)then
toast('error',t('arg.module',id))return end if not shown then setShown(true)end bar.close()if Theme.touch then for _,p
in panels do p.close()end end closeModules(id)local p=modulePanels[id]if not p then p=ModulePanel.new(layer,uiJan,common
,id)modulePanels[id]=p end p.open()end openAvatar=function(tab)if not shown then setShown(true)end bar.close()if Theme.
touch then for _,p in panels do p.close()end closeModules('avatar')end local a=avatar if not a then local ok,made=pcall(
AvatarPanel.new,layer,uiJan,common)if not ok then deps.log:Error('avatar panel: '..tostring(made))toast('error',t(
'err.failed','avatar',tostring(made)))return end a=made avatar=made end(a).open(tab)end local function build()local
reopen={}for id,p in panels do if p.isOpen()then table.insert(reopen,id)end end local reopenModules={}for id,p in
modulePanels do if p.isOpen()then table.insert(reopenModules,id)end end local reopenAvatar=avatar~=nil and(avatar).
isOpen()uiJan:Cleanup()table.clear(panels)table.clear(modulePanels)avatar=nil wheel=nil launcher=nil gui=new('ScreenGui'
,{Name='TZAR_Admin',ResetOnSpawn=false,IgnoreGuiInset=true,DisplayOrder=1001,ZIndexBehavior=Enum.ZIndexBehavior.Sibling}
)uiJan:Add(gui)layer=new('Frame',{Name='Layer',BackgroundTransparency=1,Size=UDim2.fromScale(1,1),Visible=shown,Parent=
gui})toasts=Toasts.new(gui,store)common={registry=reg,store=store,t=t,run=runLine,capture=deps.capture,openPanel=
function(id)openPanel(id)end,isPinned=isPinned,togglePin=togglePin,modules=deps.modules,openModule=function(id)
openModule(id)end,toast=toast,i18n=deps.i18n,log=deps.log,info=deps.info,setLang=function(code)if deps.i18n:SetLang(code
)then store.data.lang=code store:Save('lang')end end,openBar=function(prefill)openBar(prefill)end,unload=deps.unload}
dock=Dock.new(layer,uiJan,((setmetatable({quick=quick,openPins=function()openPanel('pins')end},{__index=common}))))if
not Theme.touch then launcher=Launcher.new(layer,uiJan,t('pn.commands'),';',function()openBar(nil)end)end bar=Spotlight.
new(layer,uiJan,((setmetatable({quick=quick},{__index=common}))))wheel=EmoteWheel.new(layer,uiJan,common)gui.Parent=deps
.parent for _,id in reopen do openPanel(id)end for _,id in reopenModules do openModule(id)end if reopenAvatar then
openAvatar(nil)end end build()jan:Add(reg.StateChanged:Connect(function()bar.refresh()local p=panels.commands if p and p
.isOpen()then builders.commands(p)end end))jan:Add(deps.i18n.Changed:Connect(function()build()end))local function 
debugInfo()local open={}for id,p in panels do open[id]=p.frame end local mods={}for id,p in modulePanels do mods[id]=p.
frame end local a=avatar local w=wheel return{gui=gui,layer=layer,bar=bar.frame,barOpen=bar.isOpen(),barInput=bar.input,
dock=dock.frame,launcher=launcher,panels=open,modules=mods,avatar=if a then a.frame else nil,wheel=if w then w.frame()
else nil,shown=shown}end return{toast=toast,notify=function(title,text)if toasts then toasts.notify(title,text)end end,
openBar=function(prefill)openBar(prefill)end,closeBar=function()bar.close()end,toggleAll=function()setShown(not shown)
end,openPanel=function(id)openPanel(id)end,closePanel=function(id)closePanel(id)end,openView=function(view)if view==
'avatar'then openAvatar(nil)return elseif view=='emotewheel'then local w=wheel if w then w.toggle()end return end if
view=='settings'or view=='log'or view=='binds'or view=='commands'or view=='pins'then openPanel(view)else openPanel(
'commands')end end,openModule=function(id)openModule(id)end,openAvatar=function(tab)openAvatar(tab)end,closeAvatar=
function()local a=avatar if a then a.close()end end,toggleWheel=function()local w=wheel if w then w.toggle()end end,
closeModule=function(id)local p=modulePanels[id]if p then p.close()end end,popover=function(name)local spec=reg:Get(name
)if spec then dock.popover(spec)end end,visible=function()return shown end,gui=function()return gui end,rebuild=build,
debug=debugInfo,destroy=function()jan:Cleanup()end}end return App end function __DARKLUA_BUNDLE_MODULES.N()local v=
__DARKLUA_BUNDLE_MODULES.cache.N if not v then v={c=__modImpl()}__DARKLUA_BUNDLE_MODULES.cache.N=v end return v.c end
end do local function __modImpl()local UserInputService=game:GetService('UserInputService')local Janitor=
__DARKLUA_BUNDLE_MODULES.j()local Store=__DARKLUA_BUNDLE_MODULES.l()local Binds={}Binds.__index=Binds function Binds.new
(store,handlers)local jan=Janitor.new()local self={_jan=jan,_capture=nil}jan:Connect(UserInputService.InputBegan,
function(input,processed)if input.UserInputType~=Enum.UserInputType.Keyboard then return end local key=input.KeyCode
local capture=self._capture if capture then self._capture=nil capture(key)return end if UserInputService:
GetFocusedTextBox()then return end local data=store.data if key.Name==data.toggleKey then handlers.toggleAll()return end
if processed then return end if key.Name==data.paletteKey then task.defer(handlers.openBar)return end local line=data.
binds[key.Name]if line then handlers.run(line)end end)jan:Connect(UserInputService.InputEnded,function(input)if input.
UserInputType~=Enum.UserInputType.Keyboard then return end local name=input.KeyCode.Name local line=store.data.binds[
name]if line and store.data.holdBinds[name]then local word=string.match(line,'^%S+')if word then handlers.run('un'..word
)end end end)return((setmetatable(self,Binds)))end function Binds.Capture(self,fn)self._capture=fn end function Binds.
Destroy(self)self._capture=nil self._jan:Cleanup()end return Binds end function __DARKLUA_BUNDLE_MODULES.O()local v=
__DARKLUA_BUNDLE_MODULES.cache.O if not v then v={c=__modImpl()}__DARKLUA_BUNDLE_MODULES.cache.O=v end return v.c end
end do local function __modImpl()local Types=__DARKLUA_BUNDLE_MODULES.c()local specs={{name='avatar',icon='user',
category='avatar',kind='action',module='avatar'},{name='emotewheel',icon='sparkles',aliases={'wheel'},category='avatar',
kind='action',module='avatar'},{name='wear',icon='user',aliases={'char'},category='avatar',kind='value',module='avatar',
respawn=true,args={{name='user',kind='user'}}},{name='outfit',icon='star',category='avatar',kind='value',module='avatar'
,respawn=true,args={{name='outfit',kind='outfit'}}},{name='bundle',icon='box',category='avatar',kind='value',module=
'avatar',respawn=true,args={{name='bundle id',kind='string'}}},{name='saveoutfit',icon='plus',category='avatar',kind=
'action',module='avatar',args={{name='name',kind='rest',optional=true}}},{name='renameoutfit',icon='list',category=
'avatar',kind='action',module='avatar',args={{name='outfit',kind='outfit'},{name='name',kind='rest'}}},{name='deloutfit'
,icon='x',category='avatar',kind='action',module='avatar',args={{name='outfit',kind='outfit'}}},{name='outfits',icon=
'list',category='avatar',kind='action',module='avatar'},{name='exportoutfit',icon='arrow-right',category='avatar',kind=
'action',module='avatar',needs={'writefile'},args={{name='outfit',kind='outfit',optional=true}}},{name='avatarrules',
icon='check',category='avatar',kind='toggle',module='avatar'},{name='emote',icon='sparkles',aliases={'e'},category=
'avatar',kind='action',module='avatar',args={{name='emote',kind='emote'}}},{name='addemote',icon='plus',category=
'avatar',kind='action',module='avatar',args={{name='emote id',kind='string'},{name='name',kind='rest',optional=true}}},{
name='delemote',icon='x',category='avatar',kind='action',module='avatar',args={{name='emote',kind='emote'}}},{name=
'emotes',icon='list',category='avatar',kind='action',module='avatar'}}return specs end function __DARKLUA_BUNDLE_MODULES
.P()local v=__DARKLUA_BUNDLE_MODULES.cache.P if not v then v={c=__modImpl()}__DARKLUA_BUNDLE_MODULES.cache.P=v end
return v.c end end do local function __modImpl()local Types=__DARKLUA_BUNDLE_MODULES.c()local specs={{name='fly',icon=
'zap',category='character',kind='toggle',module='character',respawn=true,args={{name='speed',kind='number',optional=true
,min=1,max=500}}},{name='flyspeed',icon='gauge',category='character',kind='value',module='character',default=50,presets=
{25,50,80,120,200,300},args={{name='speed',kind='number',min=1,max=500}}},{name='noclip',icon='ghost',category=
'character',kind='toggle',module='character',respawn=true},{name='speed',icon='gauge',aliases={'ws','walkspeed'},
category='character',kind='value',module='character',respawn=true,default=16,presets={16,32,64,96,150,200},args={{name=
'speed',kind='number',min=0,max=500}}},{name='jumppower',icon='arrow-up',aliases={'jp'},category='character',kind=
'value',module='character',respawn=true,default=50,presets={50,75,100,150,250,400},args={{name='power',kind='number',min
=0,max=1000}}},{name='infjump',icon='arrow-up',category='character',kind='toggle',module='character'},{name='sit',icon=
'box',category='character',kind='action',module='character'},{name='lay',icon='menu',category='character',kind='action',
module='character'},{name='setwp',icon='map-pin',aliases={'addwp'},category='character',kind='action',module='character'
,args={{name='name',kind='rest'}}},{name='wp',icon='map-pin',aliases={'goto'},category='character',kind='action',module=
'character',args={{name='waypoint',kind='waypoint'}}},{name='delwp',icon='map-pin',category='character',kind='action',
module='character',args={{name='waypoint',kind='waypoint'}}},{name='waypoints',icon='map-pin',aliases={'wps'},category=
'character',kind='action',module='character'},{name='antiafk',icon='clock',category='character',kind='toggle',module=
'character'},{name='respawn',icon='refresh',aliases={'re'},category='character',kind='action',module='character'},{name=
'refresh',icon='map-pin',aliases={'ref'},category='character',kind='action',module='character'}}return specs end
function __DARKLUA_BUNDLE_MODULES.Q()local v=__DARKLUA_BUNDLE_MODULES.cache.Q if not v then v={c=__modImpl()}
__DARKLUA_BUNDLE_MODULES.cache.Q=v end return v.c end end do local function __modImpl()local Types=
__DARKLUA_BUNDLE_MODULES.c()local specs={{name='help',icon='info',aliases={'cmds','?'},category='hub',kind='action',
module='hub',args={{name='command',kind='command',optional=true}}},{name='bind',icon='key',category='hub',kind='action',
module='hub',args={{name='key',kind='key'},{name='command',kind='rest'}}},{name='unbind',icon='key',category='hub',kind=
'action',module='hub',args={{name='key',kind='key'}}},{name='binds',icon='key',category='hub',kind='action',module='hub'
},{name='togglekey',icon='keyboard',category='hub',kind='action',module='hub',args={{name='key',kind='key',optional=true
}}},{name='lang',icon='globe',aliases={'language'},category='hub',kind='action',module='hub',args={{name='lang',kind=
'enum',options={'ru','en','uk','es','pt','de'}}}},{name='enable',icon='check',category='hub',kind='action',module='hub',
args={{name='command',kind='command'}}},{name='disable',icon='x',category='hub',kind='action',module='hub',args={{name=
'command',kind='command'}}},{name='settings',icon='settings',category='hub',kind='action',module='hub'},{name='log',icon
='message',aliases={'logs'},category='hub',kind='action',module='hub'},{name='module',icon='box',aliases={'mod'},
category='hub',kind='action',module='hub',args={{name='module',kind='module',optional=true}}},{name='preset',icon=
'sparkles',category='hub',kind='action',module='hub',args={{name='set',kind='preset'}}},{name='unload',icon='log-out',
aliases={'exit'},category='hub',kind='action',module='hub'}}return specs end function __DARKLUA_BUNDLE_MODULES.R()local
v=__DARKLUA_BUNDLE_MODULES.cache.R if not v then v={c=__modImpl()}__DARKLUA_BUNDLE_MODULES.cache.R=v end return v.c end
end do local function __modImpl()local Types=__DARKLUA_BUNDLE_MODULES.c()local bundle={en={['ui.search']=
'Command or player',['ui.tab_all']='All',['cat.avatar']='Avatar',['cat.character']='Character',['cat.camera']='Camera',[
'cat.visual']='Visual',['cat.utility']='Utilities',['cat.hub']='Hub',['ui.players']='Players',['ui.commands']='Commands'
,['ui.nothing']='Nothing found',['ui.keys']='\u{2191}\u{2193} \u{b7} TAB \u{b7} ENTER',['ui.n_players']={'%d PLAYER',
'%d PLAYERS'},['ui.why.display']='display',['ui.why.name']='name',['ui.why.me']='you',['ui.ready']='READY \u{b7} %d MS',
['ui.hide_key']='%s HIDES',['ui.by_name']='By name\u{2026}',['ui.type']='Type\u{2026}',['ui.reset']='Reset',['ui.exact']
='Enter a value\u{2026}',['ui.bind']='Bind a key',['ui.bind_key']='Key: %s',['ui.press_key']='Press a key\u{2026}',[
'ui.enable_cmd']='Enable command',['ui.disable_cmd']='Disable command',['ui.missing']='no %s',['ui.off']='off',['ui.on']
='on',['ui.empty_outfit']='No saved outfits yet',['ui.empty_waypoint']='No waypoints yet: setwp <name>',[
'ui.empty_emote']='No emotes yet',['ui.close_again']='Press \u{d7} again to turn the hub off',['toast.on']='%s: on',[
'toast.off']='%s: off',['toast.value']='%s: %s',['toast.reset']='%s: back to default',['toast.bound']='%s \u{2192} %s',[
'toast.unbound']='%s unbound',['toast.cmd_enabled']='%s enabled',['toast.cmd_disabled']='%s disabled',['toast.loaded']=
[[TZAR Admin is ready. %s shows the window, %s opens the command line.]],['toast.loaded_touch']=
'TZAR Admin is ready. The T button opens it.',['toast.unloaded']='TZAR Admin is off',['err.unknown']=
'No command \u{201c}%s\u{201d}',['err.unknown_near']='No command \u{201c}%s\u{201d}. Did you mean %s?',['err.disabled']=
'%s is disabled. Enable it in settings.',['err.needs']='%s needs %s, and this executor does not have it',['err.arg']=
'%s: %s',['err.failed']='%s failed: %s',['arg.missing']='missing %s',['arg.number']='needs a number from %s to %s',[
'arg.boolean']='on or off',['arg.enum']='options: %s',['arg.player']='no player \u{201c}%s\u{201d} on this server',[
'arg.key']='no key \u{201c}%s\u{201d}',['arg.command']='no command \u{201c}%s\u{201d}',['arg.outfit']=
'no outfit \u{201c}%s\u{201d}',['arg.waypoint']='no waypoint \u{201c}%s\u{201d}',['arg.emote']=
'no emote \u{201c}%s\u{201d}',['set.lang']='Language',['set.keys']='Keys',['set.toggle_key']='Show window',[
'set.palette_key']='Command line',['set.binds']='Binds',['set.no_binds']=
'No binds yet. Right-click a command to bind a key.',['set.disabled']='Disabled commands',['set.chat']=
'Commands from chat',['set.chat_hint']=
[[Messages starting with ; run as commands. Other players still see the message.]],['set.more']='More',['set.log']='Log'
,['set.unload']='Turn off hub',['set.back']='Back',['set.log_empty']='The log is empty',['set.info']=
'%s %s \u{b7} started in %d ms \u{b7} %d commands'},ru={['ui.search']=
'\u{41a}\u{43e}\u{43c}\u{430}\u{43d}\u{434}\u{430} \u{438}\u{43b}\u{438} \u{438}\u{433}\u{440}\u{43e}\u{43a}',[
'ui.tab_all']='\u{412}\u{441}\u{435}',['cat.avatar']='\u{410}\u{432}\u{430}\u{442}\u{430}\u{440}',['cat.character']=
'\u{41f}\u{435}\u{440}\u{441}\u{43e}\u{43d}\u{430}\u{436}',['cat.camera']='\u{41a}\u{430}\u{43c}\u{435}\u{440}\u{430}',[
'cat.visual']='\u{412}\u{438}\u{437}\u{443}\u{430}\u{43b}',['cat.utility']=
'\u{423}\u{442}\u{438}\u{43b}\u{438}\u{442}\u{44b}',['cat.hub']='\u{425}\u{430}\u{431}',['ui.players']=
'\u{418}\u{433}\u{440}\u{43e}\u{43a}\u{438}',['ui.commands']='\u{41a}\u{43e}\u{43c}\u{430}\u{43d}\u{434}\u{44b}',[
'ui.nothing']=
'\u{41d}\u{438}\u{447}\u{435}\u{433}\u{43e} \u{43d}\u{435} \u{43d}\u{430}\u{439}\u{434}\u{435}\u{43d}\u{43e}',['ui.keys'
]='\u{2191}\u{2193} \u{b7} TAB \u{b7} ENTER',['ui.n_players']={'%d \u{418}\u{413}\u{420}\u{41e}\u{41a}',
'%d \u{418}\u{413}\u{420}\u{41e}\u{41a}\u{410}','%d \u{418}\u{413}\u{420}\u{41e}\u{41a}\u{41e}\u{412}'},[
'ui.why.display']='display',['ui.why.name']='\u{43d}\u{438}\u{43a}',['ui.why.me']='\u{432}\u{44b}',['ui.ready']=
'\u{413}\u{41e}\u{422}\u{41e}\u{412} \u{b7} %d MS',['ui.hide_key']='%s \u{421}\u{41a}\u{420}\u{42b}\u{422}\u{42c}',[
'ui.by_name']='\u{41f}\u{43e} \u{43d}\u{438}\u{43a}\u{443}\u{2026}',['ui.type']=
'\u{412}\u{432}\u{435}\u{441}\u{442}\u{438}\u{2026}',['ui.reset']=
'\u{421}\u{431}\u{440}\u{43e}\u{441}\u{438}\u{442}\u{44c}',['ui.exact']=
'\u{412}\u{432}\u{435}\u{441}\u{442}\u{438} \u{437}\u{43d}\u{430}\u{447}\u{435}\u{43d}\u{438}\u{435}\u{2026}',['ui.bind'
]='\u{41d}\u{430}\u{437}\u{43d}\u{430}\u{447}\u{438}\u{442}\u{44c} \u{43a}\u{43b}\u{430}\u{432}\u{438}\u{448}\u{443}',[
'ui.bind_key']='\u{41a}\u{43b}\u{430}\u{432}\u{438}\u{448}\u{430}: %s',['ui.press_key']=
'\u{41d}\u{430}\u{436}\u{43c}\u{438}\u{442}\u{435} \u{43a}\u{43b}\u{430}\u{432}\u{438}\u{448}\u{443}\u{2026}',[
'ui.enable_cmd']=
'\u{412}\u{43a}\u{43b}\u{44e}\u{447}\u{438}\u{442}\u{44c} \u{43a}\u{43e}\u{43c}\u{430}\u{43d}\u{434}\u{443}',[
'ui.disable_cmd']=
'\u{412}\u{44b}\u{43a}\u{43b}\u{44e}\u{447}\u{438}\u{442}\u{44c} \u{43a}\u{43e}\u{43c}\u{430}\u{43d}\u{434}\u{443}',[
'ui.missing']='\u{43d}\u{435}\u{442} %s',['ui.off']='\u{432}\u{44b}\u{43a}\u{43b}',['ui.on']='\u{432}\u{43a}\u{43b}',[
'ui.empty_outfit']=
'\u{421}\u{43e}\u{445}\u{440}\u{430}\u{43d}\u{451}\u{43d}\u{43d}\u{44b}\u{445} \u{43e}\u{431}\u{440}\u{430}\u{437}\u{43e}\u{432} \u{43f}\u{43e}\u{43a}\u{430} \u{43d}\u{435}\u{442}'
,['ui.empty_waypoint']=
'\u{422}\u{43e}\u{447}\u{435}\u{43a} \u{43f}\u{43e}\u{43a}\u{430} \u{43d}\u{435}\u{442}: setwp <\u{438}\u{43c}\u{44f}>',
['ui.empty_emote']='\u{42d}\u{43c}\u{43e}\u{446}\u{438}\u{439} \u{43f}\u{43e}\u{43a}\u{430} \u{43d}\u{435}\u{442}',[
'ui.close_again']=
'\u{41d}\u{430}\u{436}\u{43c}\u{438}\u{442}\u{435} \u{d7} \u{435}\u{449}\u{451} \u{440}\u{430}\u{437}, \u{447}\u{442}\u{43e}\u{431}\u{44b} \u{432}\u{44b}\u{43a}\u{43b}\u{44e}\u{447}\u{438}\u{442}\u{44c} \u{445}\u{430}\u{431}'
,['toast.on']='%s: \u{432}\u{43a}\u{43b}',['toast.off']='%s: \u{432}\u{44b}\u{43a}\u{43b}',['toast.value']='%s: %s',[
'toast.reset']='%s: \u{43a}\u{430}\u{43a} \u{431}\u{44b}\u{43b}\u{43e}',['toast.bound']='%s \u{2192} %s',[
'toast.unbound']='\u{411}\u{438}\u{43d}\u{434} %s \u{441}\u{43d}\u{44f}\u{442}',['toast.cmd_enabled']=
'%s \u{432}\u{43a}\u{43b}\u{44e}\u{447}\u{435}\u{43d}\u{430}',['toast.cmd_disabled']=
'%s \u{432}\u{44b}\u{43a}\u{43b}\u{44e}\u{447}\u{435}\u{43d}\u{430}',['toast.loaded']=
'TZAR Admin \u{433}\u{43e}\u{442}\u{43e}\u{432}. %s \u{43f}\u{43e}\u{43a}\u{430}\u{437}\u{44b}\u{432}\u{430}\u{435}\u{442} \u{43e}\u{43a}\u{43d}\u{43e}, %s \u{43e}\u{442}\u{43a}\u{440}\u{44b}\u{432}\u{430}\u{435}\u{442} \u{441}\u{442}\u{440}\u{43e}\u{43a}\u{443} \u{43a}\u{43e}\u{43c}\u{430}\u{43d}\u{434}.'
,['toast.loaded_touch']=
'TZAR Admin \u{433}\u{43e}\u{442}\u{43e}\u{432}. \u{41a}\u{43d}\u{43e}\u{43f}\u{43a}\u{430} T \u{43e}\u{442}\u{43a}\u{440}\u{44b}\u{432}\u{430}\u{435}\u{442} \u{43e}\u{43a}\u{43d}\u{43e}.'
,['toast.unloaded']='TZAR Admin \u{432}\u{44b}\u{43a}\u{43b}\u{44e}\u{447}\u{435}\u{43d}',['err.unknown']=
'\u{41d}\u{435}\u{442} \u{43a}\u{43e}\u{43c}\u{430}\u{43d}\u{434}\u{44b} \u{ab}%s\u{bb}',['err.unknown_near']=
'\u{41d}\u{435}\u{442} \u{43a}\u{43e}\u{43c}\u{430}\u{43d}\u{434}\u{44b} \u{ab}%s\u{bb}. \u{41c}\u{43e}\u{436}\u{435}\u{442}, %s?'
,['err.disabled']=
'%s \u{432}\u{44b}\u{43a}\u{43b}\u{44e}\u{447}\u{435}\u{43d}\u{430}. \u{412}\u{43a}\u{43b}\u{44e}\u{447}\u{438}\u{442}\u{44c} \u{43c}\u{43e}\u{436}\u{43d}\u{43e} \u{432} \u{43d}\u{430}\u{441}\u{442}\u{440}\u{43e}\u{439}\u{43a}\u{430}\u{445}.'
,['err.needs']=
'%s \u{43d}\u{443}\u{436}\u{43d}\u{430} \u{444}\u{443}\u{43d}\u{43a}\u{446}\u{438}\u{44f} %s, \u{430} \u{443} \u{44d}\u{442}\u{43e}\u{433}\u{43e} \u{438}\u{441}\u{43f}\u{43e}\u{43b}\u{43d}\u{438}\u{442}\u{435}\u{43b}\u{44f} \u{435}\u{451} \u{43d}\u{435}\u{442}'
,['err.arg']='%s: %s',['err.failed']='%s \u{443}\u{43f}\u{430}\u{43b}\u{430}: %s',['arg.missing']=
'\u{43d}\u{443}\u{436}\u{435}\u{43d} \u{430}\u{440}\u{433}\u{443}\u{43c}\u{435}\u{43d}\u{442} %s',['arg.number']=
'\u{43d}\u{443}\u{436}\u{43d}\u{43e} \u{447}\u{438}\u{441}\u{43b}\u{43e} \u{43e}\u{442} %s \u{434}\u{43e} %s',[
'arg.boolean']='on \u{438}\u{43b}\u{438} off',['arg.enum']=
'\u{432}\u{430}\u{440}\u{438}\u{430}\u{43d}\u{442}\u{44b}: %s',['arg.player']=
'\u{43d}\u{430} \u{441}\u{435}\u{440}\u{432}\u{435}\u{440}\u{435} \u{43d}\u{435}\u{442} \u{438}\u{433}\u{440}\u{43e}\u{43a}\u{430} \u{ab}%s\u{bb}'
,['arg.key']='\u{43d}\u{435}\u{442} \u{43a}\u{43b}\u{430}\u{432}\u{438}\u{448}\u{438} \u{ab}%s\u{bb}',['arg.command']=
'\u{43d}\u{435}\u{442} \u{43a}\u{43e}\u{43c}\u{430}\u{43d}\u{434}\u{44b} \u{ab}%s\u{bb}',['arg.outfit']=
'\u{43d}\u{435}\u{442} \u{43e}\u{431}\u{440}\u{430}\u{437}\u{430} \u{ab}%s\u{bb}',['arg.waypoint']=
'\u{43d}\u{435}\u{442} \u{442}\u{43e}\u{447}\u{43a}\u{438} \u{ab}%s\u{bb}',['arg.emote']=
'\u{43d}\u{435}\u{442} \u{44d}\u{43c}\u{43e}\u{446}\u{438}\u{438} \u{ab}%s\u{bb}',['set.lang']=
'\u{42f}\u{437}\u{44b}\u{43a}',['set.keys']='\u{41a}\u{43b}\u{430}\u{432}\u{438}\u{448}\u{438}',['set.toggle_key']=
'\u{41f}\u{43e}\u{43a}\u{430}\u{437}\u{430}\u{442}\u{44c} \u{43e}\u{43a}\u{43d}\u{43e}',['set.palette_key']=
'\u{421}\u{442}\u{440}\u{43e}\u{43a}\u{430} \u{43a}\u{43e}\u{43c}\u{430}\u{43d}\u{434}',['set.binds']=
'\u{411}\u{438}\u{43d}\u{434}\u{44b}',['set.no_binds']=
'\u{411}\u{438}\u{43d}\u{434}\u{43e}\u{432} \u{43f}\u{43e}\u{43a}\u{430} \u{43d}\u{435}\u{442}. \u{41f}\u{440}\u{430}\u{432}\u{44b}\u{439} \u{43a}\u{43b}\u{438}\u{43a} \u{43f}\u{43e} \u{43a}\u{43e}\u{43c}\u{430}\u{43d}\u{434}\u{435} \u{43d}\u{430}\u{437}\u{43d}\u{430}\u{447}\u{430}\u{435}\u{442} \u{43a}\u{43b}\u{430}\u{432}\u{438}\u{448}\u{443}.'
,['set.disabled']=
'\u{412}\u{44b}\u{43a}\u{43b}\u{44e}\u{447}\u{435}\u{43d}\u{43d}\u{44b}\u{435} \u{43a}\u{43e}\u{43c}\u{430}\u{43d}\u{434}\u{44b}'
,['set.chat']='\u{41a}\u{43e}\u{43c}\u{430}\u{43d}\u{434}\u{44b} \u{438}\u{437} \u{447}\u{430}\u{442}\u{430}',[
'set.chat_hint']=
'\u{421}\u{43e}\u{43e}\u{431}\u{449}\u{435}\u{43d}\u{438}\u{44f} \u{441} ; \u{432} \u{43d}\u{430}\u{447}\u{430}\u{43b}\u{435} \u{432}\u{44b}\u{43f}\u{43e}\u{43b}\u{43d}\u{44f}\u{44e}\u{442}\u{441}\u{44f} \u{43a}\u{430}\u{43a} \u{43a}\u{43e}\u{43c}\u{430}\u{43d}\u{434}\u{44b}. \u{414}\u{440}\u{443}\u{433}\u{438}\u{435} \u{438}\u{433}\u{440}\u{43e}\u{43a}\u{438} \u{432}\u{441}\u{451} \u{440}\u{430}\u{432}\u{43d}\u{43e} \u{432}\u{438}\u{434}\u{44f}\u{442} \u{441}\u{43e}\u{43e}\u{431}\u{449}\u{435}\u{43d}\u{438}\u{435}.'
,['set.more']='\u{415}\u{449}\u{451}',['set.log']='\u{41b}\u{43e}\u{433}',['set.unload']=
'\u{412}\u{44b}\u{43a}\u{43b}\u{44e}\u{447}\u{438}\u{442}\u{44c} \u{445}\u{430}\u{431}',['set.back']=
'\u{41d}\u{430}\u{437}\u{430}\u{434}',['set.log_empty']='\u{41b}\u{43e}\u{433} \u{43f}\u{443}\u{441}\u{442}',['set.info'
]=
'%s %s \u{b7} \u{441}\u{442}\u{430}\u{440}\u{442} \u{437}\u{430} %d \u{43c}\u{441} \u{b7} \u{43a}\u{43e}\u{43c}\u{430}\u{43d}\u{434}: %d'
},uk={['ui.search']=
'\u{41a}\u{43e}\u{43c}\u{430}\u{43d}\u{434}\u{430} \u{430}\u{431}\u{43e} \u{433}\u{440}\u{430}\u{432}\u{435}\u{446}\u{44c}'
,['ui.tab_all']='\u{423}\u{441}\u{456}',['cat.avatar']='\u{410}\u{432}\u{430}\u{442}\u{430}\u{440}',['cat.character']=
'\u{41f}\u{435}\u{440}\u{441}\u{43e}\u{43d}\u{430}\u{436}',['cat.camera']='\u{41a}\u{430}\u{43c}\u{435}\u{440}\u{430}',[
'cat.visual']='\u{412}\u{456}\u{437}\u{443}\u{430}\u{43b}',['cat.utility']=
'\u{423}\u{442}\u{438}\u{43b}\u{456}\u{442}\u{438}',['cat.hub']='\u{425}\u{430}\u{431}',['ui.players']=
'\u{413}\u{440}\u{430}\u{432}\u{446}\u{456}',['ui.commands']='\u{41a}\u{43e}\u{43c}\u{430}\u{43d}\u{434}\u{438}',[
'ui.nothing']=
'\u{41d}\u{456}\u{447}\u{43e}\u{433}\u{43e} \u{43d}\u{435} \u{437}\u{43d}\u{430}\u{439}\u{434}\u{435}\u{43d}\u{43e}',[
'ui.keys']='\u{2191}\u{2193} \u{b7} TAB \u{b7} ENTER',['ui.n_players']={
'%d \u{413}\u{420}\u{410}\u{412}\u{415}\u{426}\u{42c}','%d \u{413}\u{420}\u{410}\u{412}\u{426}\u{406}',
'%d \u{413}\u{420}\u{410}\u{412}\u{426}\u{406}\u{412}'},['ui.why.display']='display',['ui.why.name']=
'\u{43d}\u{456}\u{43a}',['ui.why.me']='\u{432}\u{438}',['ui.ready']=
'\u{413}\u{41e}\u{422}\u{41e}\u{412}\u{41e} \u{b7} %d MS',['ui.hide_key']=
'%s \u{421}\u{425}\u{41e}\u{412}\u{410}\u{422}\u{418}',['ui.by_name']=
'\u{417}\u{430} \u{43d}\u{456}\u{43a}\u{43e}\u{43c}\u{2026}',['ui.type']=
'\u{412}\u{432}\u{435}\u{441}\u{442}\u{438}\u{2026}',['ui.reset']='\u{421}\u{43a}\u{438}\u{43d}\u{443}\u{442}\u{438}',[
'ui.exact']=
'\u{412}\u{432}\u{435}\u{441}\u{442}\u{438} \u{437}\u{43d}\u{430}\u{447}\u{435}\u{43d}\u{43d}\u{44f}\u{2026}',['ui.bind'
]=
'\u{41f}\u{440}\u{438}\u{437}\u{43d}\u{430}\u{447}\u{438}\u{442}\u{438} \u{43a}\u{43b}\u{430}\u{432}\u{456}\u{448}\u{443}'
,['ui.bind_key']='\u{41a}\u{43b}\u{430}\u{432}\u{456}\u{448}\u{430}: %s',['ui.press_key']=
'\u{41d}\u{430}\u{442}\u{438}\u{441}\u{43d}\u{456}\u{442}\u{44c} \u{43a}\u{43b}\u{430}\u{432}\u{456}\u{448}\u{443}\u{2026}'
,['ui.enable_cmd']=
'\u{423}\u{432}\u{456}\u{43c}\u{43a}\u{43d}\u{443}\u{442}\u{438} \u{43a}\u{43e}\u{43c}\u{430}\u{43d}\u{434}\u{443}',[
'ui.disable_cmd']=
'\u{412}\u{438}\u{43c}\u{43a}\u{43d}\u{443}\u{442}\u{438} \u{43a}\u{43e}\u{43c}\u{430}\u{43d}\u{434}\u{443}',[
'ui.missing']='\u{43d}\u{435}\u{43c}\u{430}\u{454} %s',['ui.off']='\u{432}\u{438}\u{43c}\u{43a}',['ui.on']=
'\u{443}\u{432}\u{456}\u{43c}\u{43a}',['ui.empty_outfit']=
'\u{417}\u{431}\u{435}\u{440}\u{435}\u{436}\u{435}\u{43d}\u{438}\u{445} \u{43e}\u{431}\u{440}\u{430}\u{437}\u{456}\u{432} \u{43f}\u{43e}\u{43a}\u{438} \u{43d}\u{435}\u{43c}\u{430}\u{454}'
,['ui.empty_waypoint']=
'\u{422}\u{43e}\u{447}\u{43e}\u{43a} \u{43f}\u{43e}\u{43a}\u{438} \u{43d}\u{435}\u{43c}\u{430}\u{454}: setwp <\u{43d}\u{430}\u{437}\u{432}\u{430}>'
,['ui.empty_emote']=
'\u{415}\u{43c}\u{43e}\u{446}\u{456}\u{439} \u{43f}\u{43e}\u{43a}\u{438} \u{43d}\u{435}\u{43c}\u{430}\u{454}',[
'ui.close_again']=
'\u{41d}\u{430}\u{442}\u{438}\u{441}\u{43d}\u{456}\u{442}\u{44c} \u{d7} \u{449}\u{435} \u{440}\u{430}\u{437}, \u{449}\u{43e}\u{431} \u{432}\u{438}\u{43c}\u{43a}\u{43d}\u{443}\u{442}\u{438} \u{445}\u{430}\u{431}'
,['toast.on']='%s: \u{443}\u{432}\u{456}\u{43c}\u{43a}',['toast.off']='%s: \u{432}\u{438}\u{43c}\u{43a}',['toast.value']
='%s: %s',['toast.reset']='%s: \u{44f}\u{43a} \u{431}\u{443}\u{43b}\u{43e}',['toast.bound']='%s \u{2192} %s',[
'toast.unbound']='\u{411}\u{456}\u{43d}\u{434} %s \u{437}\u{43d}\u{44f}\u{442}\u{43e}',['toast.cmd_enabled']=
'%s \u{443}\u{432}\u{456}\u{43c}\u{43a}\u{43d}\u{435}\u{43d}\u{43e}',['toast.cmd_disabled']=
'%s \u{432}\u{438}\u{43c}\u{43a}\u{43d}\u{435}\u{43d}\u{43e}',['toast.loaded']=
'TZAR Admin \u{433}\u{43e}\u{442}\u{43e}\u{432}\u{438}\u{439}. %s \u{43f}\u{43e}\u{43a}\u{430}\u{437}\u{443}\u{454} \u{432}\u{456}\u{43a}\u{43d}\u{43e}, %s \u{432}\u{456}\u{434}\u{43a}\u{440}\u{438}\u{432}\u{430}\u{454} \u{440}\u{44f}\u{434}\u{43e}\u{43a} \u{43a}\u{43e}\u{43c}\u{430}\u{43d}\u{434}.'
,['toast.loaded_touch']=
'TZAR Admin \u{433}\u{43e}\u{442}\u{43e}\u{432}\u{438}\u{439}. \u{41a}\u{43d}\u{43e}\u{43f}\u{43a}\u{430} T \u{432}\u{456}\u{434}\u{43a}\u{440}\u{438}\u{432}\u{430}\u{454} \u{432}\u{456}\u{43a}\u{43d}\u{43e}.'
,['toast.unloaded']='TZAR Admin \u{432}\u{438}\u{43c}\u{43a}\u{43d}\u{435}\u{43d}\u{43e}',['err.unknown']=
'\u{41d}\u{435}\u{43c}\u{430}\u{454} \u{43a}\u{43e}\u{43c}\u{430}\u{43d}\u{434}\u{438} \u{ab}%s\u{bb}',[
'err.unknown_near']=
'\u{41d}\u{435}\u{43c}\u{430}\u{454} \u{43a}\u{43e}\u{43c}\u{430}\u{43d}\u{434}\u{438} \u{ab}%s\u{bb}. \u{41c}\u{43e}\u{436}\u{43b}\u{438}\u{432}\u{43e}, %s?'
,['err.disabled']=
'%s \u{432}\u{438}\u{43c}\u{43a}\u{43d}\u{435}\u{43d}\u{430}. \u{423}\u{432}\u{456}\u{43c}\u{43a}\u{43d}\u{443}\u{442}\u{438} \u{43c}\u{43e}\u{436}\u{43d}\u{430} \u{432} \u{43d}\u{430}\u{43b}\u{430}\u{448}\u{442}\u{443}\u{432}\u{430}\u{43d}\u{43d}\u{44f}\u{445}.'
,['err.needs']=
'%s \u{43f}\u{43e}\u{442}\u{440}\u{456}\u{431}\u{43d}\u{430} \u{444}\u{443}\u{43d}\u{43a}\u{446}\u{456}\u{44f} %s, \u{430} \u{432} \u{446}\u{44c}\u{43e}\u{433}\u{43e} \u{432}\u{438}\u{43a}\u{43e}\u{43d}\u{430}\u{432}\u{446}\u{44f} \u{457}\u{457} \u{43d}\u{435}\u{43c}\u{430}\u{454}'
,['err.arg']='%s: %s',['err.failed']='%s \u{432}\u{43f}\u{430}\u{43b}\u{430}: %s',['arg.missing']=
'\u{43f}\u{43e}\u{442}\u{440}\u{456}\u{431}\u{435}\u{43d} \u{430}\u{440}\u{433}\u{443}\u{43c}\u{435}\u{43d}\u{442} %s',[
'arg.number']=
'\u{43f}\u{43e}\u{442}\u{440}\u{456}\u{431}\u{43d}\u{435} \u{447}\u{438}\u{441}\u{43b}\u{43e} \u{432}\u{456}\u{434} %s \u{434}\u{43e} %s'
,['arg.boolean']='on \u{430}\u{431}\u{43e} off',['arg.enum']=
'\u{432}\u{430}\u{440}\u{456}\u{430}\u{43d}\u{442}\u{438}: %s',['arg.player']=
'\u{43d}\u{430} \u{441}\u{435}\u{440}\u{432}\u{435}\u{440}\u{456} \u{43d}\u{435}\u{43c}\u{430}\u{454} \u{433}\u{440}\u{430}\u{432}\u{446}\u{44f} \u{ab}%s\u{bb}'
,['arg.key']='\u{43d}\u{435}\u{43c}\u{430}\u{454} \u{43a}\u{43b}\u{430}\u{432}\u{456}\u{448}\u{456} \u{ab}%s\u{bb}',[
'arg.command']='\u{43d}\u{435}\u{43c}\u{430}\u{454} \u{43a}\u{43e}\u{43c}\u{430}\u{43d}\u{434}\u{438} \u{ab}%s\u{bb}',[
'arg.outfit']='\u{43d}\u{435}\u{43c}\u{430}\u{454} \u{43e}\u{431}\u{440}\u{430}\u{437}\u{443} \u{ab}%s\u{bb}',[
'arg.waypoint']='\u{43d}\u{435}\u{43c}\u{430}\u{454} \u{442}\u{43e}\u{447}\u{43a}\u{438} \u{ab}%s\u{bb}',['arg.emote']=
'\u{43d}\u{435}\u{43c}\u{430}\u{454} \u{435}\u{43c}\u{43e}\u{446}\u{456}\u{457} \u{ab}%s\u{bb}',['set.lang']=
'\u{41c}\u{43e}\u{432}\u{430}',['set.keys']='\u{41a}\u{43b}\u{430}\u{432}\u{456}\u{448}\u{456}',['set.toggle_key']=
'\u{41f}\u{43e}\u{43a}\u{430}\u{437}\u{430}\u{442}\u{438} \u{432}\u{456}\u{43a}\u{43d}\u{43e}',['set.palette_key']=
'\u{420}\u{44f}\u{434}\u{43e}\u{43a} \u{43a}\u{43e}\u{43c}\u{430}\u{43d}\u{434}',['set.binds']=
'\u{411}\u{456}\u{43d}\u{434}\u{438}',['set.no_binds']=
'\u{411}\u{456}\u{43d}\u{434}\u{456}\u{432} \u{43f}\u{43e}\u{43a}\u{438} \u{43d}\u{435}\u{43c}\u{430}\u{454}. \u{41f}\u{440}\u{430}\u{432}\u{438}\u{439} \u{43a}\u{43b}\u{456}\u{43a} \u{43f}\u{43e} \u{43a}\u{43e}\u{43c}\u{430}\u{43d}\u{434}\u{456} \u{43f}\u{440}\u{438}\u{437}\u{43d}\u{430}\u{447}\u{430}\u{454} \u{43a}\u{43b}\u{430}\u{432}\u{456}\u{448}\u{443}.'
,['set.disabled']=
'\u{412}\u{438}\u{43c}\u{43a}\u{43d}\u{435}\u{43d}\u{456} \u{43a}\u{43e}\u{43c}\u{430}\u{43d}\u{434}\u{438}',['set.chat'
]='\u{41a}\u{43e}\u{43c}\u{430}\u{43d}\u{434}\u{438} \u{437} \u{447}\u{430}\u{442}\u{443}',['set.chat_hint']=
'\u{41f}\u{43e}\u{432}\u{456}\u{434}\u{43e}\u{43c}\u{43b}\u{435}\u{43d}\u{43d}\u{44f} \u{437} ; \u{43d}\u{430} \u{43f}\u{43e}\u{447}\u{430}\u{442}\u{43a}\u{443} \u{432}\u{438}\u{43a}\u{43e}\u{43d}\u{443}\u{44e}\u{442}\u{44c}\u{441}\u{44f} \u{44f}\u{43a} \u{43a}\u{43e}\u{43c}\u{430}\u{43d}\u{434}\u{438}. \u{406}\u{43d}\u{448}\u{456} \u{433}\u{440}\u{430}\u{432}\u{446}\u{456} \u{432}\u{441}\u{435} \u{43e}\u{434}\u{43d}\u{43e} \u{431}\u{430}\u{447}\u{430}\u{442}\u{44c} \u{43f}\u{43e}\u{432}\u{456}\u{434}\u{43e}\u{43c}\u{43b}\u{435}\u{43d}\u{43d}\u{44f}.'
,['set.more']='\u{429}\u{435}',['set.log']='\u{41b}\u{43e}\u{433}',['set.unload']=
'\u{412}\u{438}\u{43c}\u{43a}\u{43d}\u{443}\u{442}\u{438} \u{445}\u{430}\u{431}',['set.back']=
'\u{41d}\u{430}\u{437}\u{430}\u{434}',['set.log_empty']=
'\u{41b}\u{43e}\u{433} \u{43f}\u{43e}\u{440}\u{43e}\u{436}\u{43d}\u{456}\u{439}',['set.info']=
'%s %s \u{b7} \u{441}\u{442}\u{430}\u{440}\u{442} \u{437}\u{430} %d \u{43c}\u{441} \u{b7} \u{43a}\u{43e}\u{43c}\u{430}\u{43d}\u{434}: %d'
},es={['ui.search']='Comando o jugador',['ui.tab_all']='Todo',['cat.avatar']='Avatar',['cat.character']='Personaje',[
'cat.camera']='C\u{e1}mara',['cat.visual']='Visual',['cat.utility']='Utilidades',['cat.hub']='Hub',['ui.players']=
'Jugadores',['ui.commands']='Comandos',['ui.nothing']='Sin resultados',['ui.keys']=
'\u{2191}\u{2193} \u{b7} TAB \u{b7} ENTER',['ui.n_players']={'%d JUGADOR','%d JUGADORES'},['ui.why.display']='display',[
'ui.why.name']='nombre',['ui.why.me']='t\u{fa}',['ui.ready']='LISTO \u{b7} %d MS',['ui.hide_key']='%s OCULTA',[
'ui.by_name']='Por nombre\u{2026}',['ui.type']='Escribir\u{2026}',['ui.reset']='Restablecer',['ui.exact']=
'Escribir un valor\u{2026}',['ui.bind']='Asignar tecla',['ui.bind_key']='Tecla: %s',['ui.press_key']=
'Pulsa una tecla\u{2026}',['ui.enable_cmd']='Activar comando',['ui.disable_cmd']='Desactivar comando',['ui.missing']=
'sin %s',['ui.off']='no',['ui.on']='s\u{ed}',['ui.empty_outfit']='A\u{fa}n no hay atuendos guardados',[
'ui.empty_waypoint']='A\u{fa}n no hay puntos: setwp <nombre>',['ui.empty_emote']='A\u{fa}n no hay emotes',[
'ui.close_again']='Pulsa \u{d7} otra vez para apagar el hub',['toast.on']='%s: activado',['toast.off']='%s: desactivado'
,['toast.value']='%s: %s',['toast.reset']='%s: valor original',['toast.bound']='%s \u{2192} %s',['toast.unbound']=
'%s sin asignar',['toast.cmd_enabled']='%s activado',['toast.cmd_disabled']='%s desactivado',['toast.loaded']=
'TZAR Admin listo. %s muestra la ventana, %s abre la l\u{ed}nea de comandos.',['toast.loaded_touch']=
'TZAR Admin listo. El bot\u{f3}n T lo abre.',['toast.unloaded']='TZAR Admin apagado',['err.unknown']=
'No existe el comando \u{ab}%s\u{bb}',['err.unknown_near']='No existe el comando \u{ab}%s\u{bb}. \u{bf}Quiz\u{e1}s %s?',
['err.disabled']='%s est\u{e1} desactivado. Act\u{ed}valo en ajustes.',['err.needs']=
'%s necesita %s y este executor no lo tiene',['err.arg']='%s: %s',['err.failed']='%s fall\u{f3}: %s',['arg.missing']=
'falta %s',['arg.number']='necesita un n\u{fa}mero de %s a %s',['arg.boolean']='on u off',['arg.enum']='opciones: %s',[
'arg.player']='no hay ning\u{fa}n jugador \u{ab}%s\u{bb} en este servidor',['arg.key']=
'no existe la tecla \u{ab}%s\u{bb}',['arg.command']='no existe el comando \u{ab}%s\u{bb}',['arg.outfit']=
'no existe el atuendo \u{ab}%s\u{bb}',['arg.waypoint']='no existe el punto \u{ab}%s\u{bb}',['arg.emote']=
'no existe el emote \u{ab}%s\u{bb}',['set.lang']='Idioma',['set.keys']='Teclas',['set.toggle_key']='Mostrar ventana',[
'set.palette_key']='L\u{ed}nea de comandos',['set.binds']='Atajos',['set.no_binds']=
'A\u{fa}n no hay atajos. Clic derecho en un comando para asignar una tecla.',['set.disabled']='Comandos desactivados',[
'set.chat']='Comandos desde el chat',['set.chat_hint']=
'Los mensajes que empiezan con ; se ejecutan como comandos. Los dem\u{e1}s igual ven el mensaje.',['set.more']=
'M\u{e1}s',['set.log']='Registro',['set.unload']='Apagar hub',['set.back']='Atr\u{e1}s',['set.log_empty']=
'El registro est\u{e1} vac\u{ed}o',['set.info']='%s %s \u{b7} inicio en %d ms \u{b7} %d comandos'},pt={['ui.search']=
'Comando ou jogador',['ui.tab_all']='Tudo',['cat.avatar']='Avatar',['cat.character']='Personagem',['cat.camera']=
'C\u{e2}mera',['cat.visual']='Visual',['cat.utility']='Utilit\u{e1}rios',['cat.hub']='Hub',['ui.players']='Jogadores',[
'ui.commands']='Comandos',['ui.nothing']='Nada encontrado',['ui.keys']='\u{2191}\u{2193} \u{b7} TAB \u{b7} ENTER',[
'ui.n_players']={'%d JOGADOR','%d JOGADORES'},['ui.why.display']='display',['ui.why.name']='nome',['ui.why.me']=
'voc\u{ea}',['ui.ready']='PRONTO \u{b7} %d MS',['ui.hide_key']='%s OCULTA',['ui.by_name']='Por nome\u{2026}',['ui.type']
='Digitar\u{2026}',['ui.reset']='Redefinir',['ui.exact']='Digitar um valor\u{2026}',['ui.bind']='Definir tecla',[
'ui.bind_key']='Tecla: %s',['ui.press_key']='Pressione uma tecla\u{2026}',['ui.enable_cmd']='Ativar comando',[
'ui.disable_cmd']='Desativar comando',['ui.missing']='sem %s',['ui.off']='n\u{e3}o',['ui.on']='sim',['ui.empty_outfit']=
'Nenhum visual salvo ainda',['ui.empty_waypoint']='Nenhum ponto ainda: setwp <nome>',['ui.empty_emote']=
'Nenhum emote ainda',['ui.close_again']='Pressione \u{d7} de novo para desligar o hub',['toast.on']='%s: ligado',[
'toast.off']='%s: desligado',['toast.value']='%s: %s',['toast.reset']='%s: valor original',['toast.bound']=
'%s \u{2192} %s',['toast.unbound']='%s sem atalho',['toast.cmd_enabled']='%s ativado',['toast.cmd_disabled']=
'%s desativado',['toast.loaded']=[[TZAR Admin pronto. %s mostra a janela, %s abre a linha de comando.]],[
'toast.loaded_touch']='TZAR Admin pronto. O bot\u{e3}o T abre a janela.',['toast.unloaded']='TZAR Admin desligado',[
'err.unknown']='Comando \u{201c}%s\u{201d} n\u{e3}o existe',['err.unknown_near']=
'Comando \u{201c}%s\u{201d} n\u{e3}o existe. Seria %s?',['err.disabled']=
'%s est\u{e1} desativado. Ative nas configura\u{e7}\u{f5}es.',['err.needs']=
'%s precisa de %s, e este executor n\u{e3}o tem',['err.arg']='%s: %s',['err.failed']='%s falhou: %s',['arg.missing']=
'falta %s',['arg.number']='precisa de um n\u{fa}mero de %s a %s',['arg.boolean']='on ou off',['arg.enum']=
'op\u{e7}\u{f5}es: %s',['arg.player']='nenhum jogador \u{201c}%s\u{201d} neste servidor',['arg.key']=
'tecla \u{201c}%s\u{201d} n\u{e3}o existe',['arg.command']='comando \u{201c}%s\u{201d} n\u{e3}o existe',['arg.outfit']=
'visual \u{201c}%s\u{201d} n\u{e3}o existe',['arg.waypoint']='ponto \u{201c}%s\u{201d} n\u{e3}o existe',['arg.emote']=
'emote \u{201c}%s\u{201d} n\u{e3}o existe',['set.lang']='Idioma',['set.keys']='Teclas',['set.toggle_key']=
'Mostrar janela',['set.palette_key']='Linha de comando',['set.binds']='Atalhos',['set.no_binds']=
'Nenhum atalho ainda. Clique com o bot\u{e3}o direito num comando para definir uma tecla.',['set.disabled']=
'Comandos desativados',['set.chat']='Comandos pelo chat',['set.chat_hint']=
'Mensagens que come\u{e7}am com ; rodam como comandos. Os outros ainda veem a mensagem.',['set.more']='Mais',['set.log']
='Registro',['set.unload']='Desligar hub',['set.back']='Voltar',['set.log_empty']='O registro est\u{e1} vazio',[
'set.info']='%s %s \u{b7} iniciou em %d ms \u{b7} %d comandos'},de={['ui.search']='Befehl oder Spieler',['ui.tab_all']=
'Alle',['cat.avatar']='Avatar',['cat.character']='Charakter',['cat.camera']='Kamera',['cat.visual']='Grafik',[
'cat.utility']='Werkzeuge',['cat.hub']='Hub',['ui.players']='Spieler',['ui.commands']='Befehle',['ui.nothing']=
'Nichts gefunden',['ui.keys']='\u{2191}\u{2193} \u{b7} TAB \u{b7} ENTER',['ui.n_players']={'%d SPIELER','%d SPIELER'},[
'ui.why.display']='display',['ui.why.name']='name',['ui.why.me']='du',['ui.ready']='BEREIT \u{b7} %d MS',['ui.hide_key']
='%s BLENDET AUS',['ui.by_name']='Nach Name\u{2026}',['ui.type']='Eingeben\u{2026}',['ui.reset']='Zur\u{fc}cksetzen',[
'ui.exact']='Wert eingeben\u{2026}',['ui.bind']='Taste zuweisen',['ui.bind_key']='Taste: %s',['ui.press_key']=
'Taste dr\u{fc}cken\u{2026}',['ui.enable_cmd']='Befehl aktivieren',['ui.disable_cmd']='Befehl deaktivieren',[
'ui.missing']='kein %s',['ui.off']='aus',['ui.on']='an',['ui.empty_outfit']='Noch keine gespeicherten Outfits',[
'ui.empty_waypoint']='Noch keine Wegpunkte: setwp <name>',['ui.empty_emote']='Noch keine Emotes',['ui.close_again']=
'Dr\u{fc}ck noch einmal \u{d7}, um den Hub auszuschalten',['toast.on']='%s: an',['toast.off']='%s: aus',['toast.value']=
'%s: %s',['toast.reset']='%s: Standardwert',['toast.bound']='%s \u{2192} %s',['toast.unbound']='%s nicht mehr belegt',[
'toast.cmd_enabled']='%s aktiviert',['toast.cmd_disabled']='%s deaktiviert',['toast.loaded']=
'TZAR Admin ist bereit. %s zeigt das Fenster, %s \u{f6}ffnet die Befehlszeile.',['toast.loaded_touch']=
'TZAR Admin ist bereit. Die T-Taste \u{f6}ffnet ihn.',['toast.unloaded']='TZAR Admin ist aus',['err.unknown']=
'Kein Befehl \u{201e}%s\u{201c}',['err.unknown_near']='Kein Befehl \u{201e}%s\u{201c}. Meintest du %s?',['err.disabled']
='%s ist deaktiviert. In den Einstellungen aktivieren.',['err.needs']='%s braucht %s, und dieser Executor hat es nicht',
['err.arg']='%s: %s',['err.failed']='%s ist fehlgeschlagen: %s',['arg.missing']='%s fehlt',['arg.number']=
'braucht eine Zahl von %s bis %s',['arg.boolean']='on oder off',['arg.enum']='Optionen: %s',['arg.player']=
'kein Spieler \u{201e}%s\u{201c} auf diesem Server',['arg.key']='keine Taste \u{201e}%s\u{201c}',['arg.command']=
'kein Befehl \u{201e}%s\u{201c}',['arg.outfit']='kein Outfit \u{201e}%s\u{201c}',['arg.waypoint']=
'kein Wegpunkt \u{201e}%s\u{201c}',['arg.emote']='kein Emote \u{201e}%s\u{201c}',['set.lang']='Sprache',['set.keys']=
'Tasten',['set.toggle_key']='Fenster zeigen',['set.palette_key']='Befehlszeile',['set.binds']='Tastenbelegung',[
'set.no_binds']=[[Noch keine Belegungen. Rechtsklick auf einen Befehl weist eine Taste zu.]],['set.disabled']=
'Deaktivierte Befehle',['set.chat']='Befehle aus dem Chat',['set.chat_hint']=
[[Nachrichten mit ; am Anfang laufen als Befehle. Andere sehen die Nachricht trotzdem.]],['set.more']='Mehr',['set.log']
='Protokoll',['set.unload']='Hub ausschalten',['set.back']='Zur\u{fc}ck',['set.log_empty']='Das Protokoll ist leer',[
'set.info']='%s %s \u{b7} Start in %d ms \u{b7} %d Befehle'}}return bundle end function __DARKLUA_BUNDLE_MODULES.S()
local v=__DARKLUA_BUNDLE_MODULES.cache.S if not v then v={c=__modImpl()}__DARKLUA_BUNDLE_MODULES.cache.S=v end return v.
c end end do local function __modImpl()local Types=__DARKLUA_BUNDLE_MODULES.c()local bundle={en={['sp.title']=
'TZAR \u{b7} Commands',['sp.stats']='%d commands \u{b7} %d on',['sp.recent']='Recent',['sp.favorites']='Favourites',[
'sp.all']='All commands by category',['sp.players']='Players \u{b7} name and display name',['sp.k_select']='select',[
'sp.k_complete']='complete',['sp.k_run']='run',['sp.k_close']='close',['sp.home_title']='Command bar',['sp.home_text']=
"Start typing a command or a player's name. Tab completes, \u{2191} in an empty bar brings back earlier lines.",[
'sp.choose_arg']='Pick %s on the left',['sp.run']='Run',['sp.state_on']='On',['sp.key']='Key',['sp.no_key']='not set',[
'sp.dock']='On the dock',['sp.also']='Also',['sp.account']='Account',['sp.days']='%d days',['sp.team']='Team',[
'pn.commands']='Commands',['pn.binds']='Binds',['pn.settings']='Settings',['pn.log']='Log',['pn.pins']='Pin to dock',[
'bd.new']='New bind',['bd.command']='Command',['bd.key']='Key',['bd.mode']='Fires',['bd.press']='on press',['bd.hold']=
'while held',['bd.add']='Add',['bd.empty']='No binds yet',['bd.need']='Type a command and press a key first',[
'bd.hold_tag']='hold',['st.lang']='Language',['st.keys']='Keys',['st.bar_key']='Command bar',['st.hide_key']=
'Hide / show TZAR',['st.behavior']='Behaviour',['st.chat']='Commands from chat',['st.sound']='Notification sound',[
'st.log']='Log',['st.errors']={'%d error','%d errors'},['st.unload']='Turn TZAR off',['dk.default']='default %s',[
'dk.reset']='Reset',['dk.type']='Type a number',['dk.done']='Done',['nt.title']='TZAR Admin is ready',['nt.pc']=
'%s opens the command bar \u{b7} %s hides TZAR',['nt.touch']=
[[The T button opens the command bar. Hold a dock button to adjust it.]]},ru={['sp.title']=
'TZAR \u{b7} \u{41a}\u{43e}\u{43c}\u{430}\u{43d}\u{434}\u{44b}',['sp.stats']=
'\u{43a}\u{43e}\u{43c}\u{430}\u{43d}\u{434}: %d \u{b7} \u{432}\u{43a}\u{43b}: %d',['sp.recent']=
'\u{41d}\u{435}\u{434}\u{430}\u{432}\u{43d}\u{438}\u{435}',['sp.favorites']=
'\u{418}\u{437}\u{431}\u{440}\u{430}\u{43d}\u{43d}\u{43e}\u{435}',['sp.all']=
'\u{412}\u{441}\u{435} \u{43a}\u{43e}\u{43c}\u{430}\u{43d}\u{434}\u{44b} \u{43f}\u{43e} \u{43a}\u{430}\u{442}\u{435}\u{433}\u{43e}\u{440}\u{438}\u{44f}\u{43c}'
,['sp.players']='\u{418}\u{433}\u{440}\u{43e}\u{43a}\u{438} \u{b7} \u{43d}\u{438}\u{43a} \u{438} display name',[
'sp.k_select']='\u{432}\u{44b}\u{431}\u{43e}\u{440}',['sp.k_complete']=
'\u{434}\u{43e}\u{43f}\u{43e}\u{43b}\u{43d}\u{438}\u{442}\u{44c}',['sp.k_run']=
'\u{432}\u{44b}\u{43f}\u{43e}\u{43b}\u{43d}\u{438}\u{442}\u{44c}',['sp.k_close']=
'\u{437}\u{430}\u{43a}\u{440}\u{44b}\u{442}\u{44c}',['sp.home_title']=
'\u{421}\u{442}\u{440}\u{43e}\u{43a}\u{430} \u{43a}\u{43e}\u{43c}\u{430}\u{43d}\u{434}',['sp.home_text']=
'\u{41d}\u{430}\u{447}\u{43d}\u{438}\u{442}\u{435} \u{432}\u{432}\u{43e}\u{434}\u{438}\u{442}\u{44c} \u{43a}\u{43e}\u{43c}\u{430}\u{43d}\u{434}\u{443} \u{438}\u{43b}\u{438} \u{43d}\u{438}\u{43a} \u{438}\u{433}\u{440}\u{43e}\u{43a}\u{430}. Tab \u{434}\u{43e}\u{43f}\u{43e}\u{43b}\u{43d}\u{44f}\u{435}\u{442}, \u{2191} \u{432} \u{43f}\u{443}\u{441}\u{442}\u{43e}\u{439} \u{441}\u{442}\u{440}\u{43e}\u{43a}\u{435} \u{432}\u{43e}\u{437}\u{432}\u{440}\u{430}\u{449}\u{430}\u{435}\u{442} \u{43f}\u{440}\u{43e}\u{448}\u{43b}\u{44b}\u{435} \u{43a}\u{43e}\u{43c}\u{430}\u{43d}\u{434}\u{44b}.'
,['sp.choose_arg']='\u{412}\u{44b}\u{431}\u{435}\u{440}\u{438}\u{442}\u{435} %s \u{441}\u{43b}\u{435}\u{432}\u{430}',[
'sp.run']='\u{412}\u{44b}\u{43f}\u{43e}\u{43b}\u{43d}\u{438}\u{442}\u{44c}',['sp.state_on']=
'\u{412}\u{43a}\u{43b}\u{44e}\u{447}\u{435}\u{43d}\u{43e}',['sp.key']=
'\u{41a}\u{43b}\u{430}\u{432}\u{438}\u{448}\u{430}',['sp.no_key']=
'\u{43d}\u{435} \u{43d}\u{430}\u{437}\u{43d}\u{430}\u{447}\u{435}\u{43d}\u{430}',['sp.dock']=
'\u{41d}\u{430} \u{434}\u{43e}\u{43a}\u{435}',['sp.also']='\u{422}\u{430}\u{43a}\u{436}\u{435}',['sp.account']=
'\u{410}\u{43a}\u{43a}\u{430}\u{443}\u{43d}\u{442}',['sp.days']='%d \u{434}\u{43d}.',['sp.team']=
'\u{41a}\u{43e}\u{43c}\u{430}\u{43d}\u{434}\u{430}',['pn.commands']='\u{41a}\u{43e}\u{43c}\u{430}\u{43d}\u{434}\u{44b}',
['pn.binds']='\u{411}\u{438}\u{43d}\u{434}\u{44b}',['pn.settings']=
'\u{41d}\u{430}\u{441}\u{442}\u{440}\u{43e}\u{439}\u{43a}\u{438}',['pn.log']='\u{41b}\u{43e}\u{433}',['pn.pins']=
'\u{417}\u{430}\u{43a}\u{440}\u{435}\u{43f}\u{438}\u{442}\u{44c} \u{43d}\u{430} \u{434}\u{43e}\u{43a}\u{435}',['bd.new']
='\u{41d}\u{43e}\u{432}\u{44b}\u{439} \u{431}\u{438}\u{43d}\u{434}',['bd.command']=
'\u{41a}\u{43e}\u{43c}\u{430}\u{43d}\u{434}\u{430}',['bd.key']='\u{41a}\u{43b}\u{430}\u{432}\u{438}\u{448}\u{430}',[
'bd.mode']='\u{421}\u{440}\u{430}\u{431}\u{430}\u{442}\u{44b}\u{432}\u{430}\u{435}\u{442}',['bd.press']=
'\u{43d}\u{430}\u{436}\u{430}\u{442}\u{438}\u{435}',['bd.hold']=
'\u{443}\u{434}\u{435}\u{440}\u{436}\u{430}\u{43d}\u{438}\u{435}',['bd.add']=
'\u{414}\u{43e}\u{431}\u{430}\u{432}\u{438}\u{442}\u{44c}',['bd.empty']=
'\u{411}\u{438}\u{43d}\u{434}\u{43e}\u{432} \u{43f}\u{43e}\u{43a}\u{430} \u{43d}\u{435}\u{442}',['bd.need']=
'\u{421}\u{43d}\u{430}\u{447}\u{430}\u{43b}\u{430} \u{432}\u{432}\u{435}\u{434}\u{438}\u{442}\u{435} \u{43a}\u{43e}\u{43c}\u{430}\u{43d}\u{434}\u{443} \u{438} \u{43d}\u{430}\u{436}\u{43c}\u{438}\u{442}\u{435} \u{43a}\u{43b}\u{430}\u{432}\u{438}\u{448}\u{443}'
,['bd.hold_tag']='\u{443}\u{434}\u{435}\u{440}\u{436}.',['st.lang']='\u{42f}\u{437}\u{44b}\u{43a}',['st.keys']=
'\u{41a}\u{43b}\u{430}\u{432}\u{438}\u{448}\u{438}',['st.bar_key']=
'\u{421}\u{442}\u{440}\u{43e}\u{43a}\u{430} \u{43a}\u{43e}\u{43c}\u{430}\u{43d}\u{434}',['st.hide_key']=
'\u{421}\u{43a}\u{440}\u{44b}\u{442}\u{44c} / \u{43f}\u{43e}\u{43a}\u{430}\u{437}\u{430}\u{442}\u{44c} TZAR',[
'st.behavior']='\u{41f}\u{43e}\u{432}\u{435}\u{434}\u{435}\u{43d}\u{438}\u{435}',['st.chat']=
'\u{41a}\u{43e}\u{43c}\u{430}\u{43d}\u{434}\u{44b} \u{438}\u{437} \u{447}\u{430}\u{442}\u{430}',['st.sound']=
'\u{417}\u{432}\u{443}\u{43a} \u{443}\u{432}\u{435}\u{434}\u{43e}\u{43c}\u{43b}\u{435}\u{43d}\u{438}\u{439}',['st.log']=
'\u{41b}\u{43e}\u{433}',['st.errors']={'%d \u{43e}\u{448}\u{438}\u{431}\u{43a}\u{430}',
'%d \u{43e}\u{448}\u{438}\u{431}\u{43a}\u{438}','%d \u{43e}\u{448}\u{438}\u{431}\u{43e}\u{43a}'},['st.unload']=
'\u{412}\u{44b}\u{43a}\u{43b}\u{44e}\u{447}\u{438}\u{442}\u{44c} TZAR',['dk.default']=
'\u{43f}\u{43e} \u{443}\u{43c}\u{43e}\u{43b}\u{447}. %s',['dk.reset']=
'\u{421}\u{431}\u{440}\u{43e}\u{441}\u{438}\u{442}\u{44c}',['dk.type']=
'\u{412}\u{432}\u{435}\u{441}\u{442}\u{438} \u{447}\u{438}\u{441}\u{43b}\u{43e}',['dk.done']=
'\u{413}\u{43e}\u{442}\u{43e}\u{432}\u{43e}',['nt.title']='TZAR Admin \u{433}\u{43e}\u{442}\u{43e}\u{432}',['nt.pc']=
'%s \u{2014} \u{441}\u{442}\u{440}\u{43e}\u{43a}\u{430} \u{43a}\u{43e}\u{43c}\u{430}\u{43d}\u{434} \u{b7} %s \u{2014} \u{441}\u{43a}\u{440}\u{44b}\u{442}\u{44c} TZAR'
,['nt.touch']=
'\u{41a}\u{43d}\u{43e}\u{43f}\u{43a}\u{430} T \u{43e}\u{442}\u{43a}\u{440}\u{44b}\u{432}\u{430}\u{435}\u{442} \u{441}\u{442}\u{440}\u{43e}\u{43a}\u{443} \u{43a}\u{43e}\u{43c}\u{430}\u{43d}\u{434}. \u{423}\u{434}\u{435}\u{440}\u{436}\u{430}\u{43d}\u{438}\u{435} \u{43a}\u{43d}\u{43e}\u{43f}\u{43a}\u{438} \u{43d}\u{430} \u{434}\u{43e}\u{43a}\u{435} \u{2014} \u{43d}\u{430}\u{441}\u{442}\u{440}\u{43e}\u{439}\u{43a}\u{430}.'
},uk={['sp.title']='TZAR \u{b7} \u{41a}\u{43e}\u{43c}\u{430}\u{43d}\u{434}\u{438}',['sp.stats']=
'\u{43a}\u{43e}\u{43c}\u{430}\u{43d}\u{434}: %d \u{b7} \u{443}\u{432}\u{456}\u{43c}\u{43a}: %d',['sp.recent']=
'\u{41d}\u{435}\u{449}\u{43e}\u{434}\u{430}\u{432}\u{43d}\u{456}',['sp.favorites']=
'\u{41e}\u{431}\u{440}\u{430}\u{43d}\u{435}',['sp.all']=
'\u{423}\u{441}\u{456} \u{43a}\u{43e}\u{43c}\u{430}\u{43d}\u{434}\u{438} \u{437}\u{430} \u{43a}\u{430}\u{442}\u{435}\u{433}\u{43e}\u{440}\u{456}\u{44f}\u{43c}\u{438}'
,['sp.players']='\u{413}\u{440}\u{430}\u{432}\u{446}\u{456} \u{b7} \u{43d}\u{456}\u{43a} \u{456} display name',[
'sp.k_select']='\u{432}\u{438}\u{431}\u{456}\u{440}',['sp.k_complete']=
'\u{434}\u{43e}\u{43f}\u{43e}\u{432}\u{43d}\u{438}\u{442}\u{438}',['sp.k_run']=
'\u{432}\u{438}\u{43a}\u{43e}\u{43d}\u{430}\u{442}\u{438}',['sp.k_close']=
'\u{437}\u{430}\u{43a}\u{440}\u{438}\u{442}\u{438}',['sp.home_title']=
'\u{420}\u{44f}\u{434}\u{43e}\u{43a} \u{43a}\u{43e}\u{43c}\u{430}\u{43d}\u{434}',['sp.home_text']=
'\u{41f}\u{43e}\u{447}\u{43d}\u{456}\u{442}\u{44c} \u{432}\u{432}\u{43e}\u{434}\u{438}\u{442}\u{438} \u{43a}\u{43e}\u{43c}\u{430}\u{43d}\u{434}\u{443} \u{430}\u{431}\u{43e} \u{43d}\u{456}\u{43a} \u{433}\u{440}\u{430}\u{432}\u{446}\u{44f}. Tab \u{434}\u{43e}\u{43f}\u{43e}\u{432}\u{43d}\u{44e}\u{454}, \u{2191} \u{443} \u{43f}\u{43e}\u{440}\u{43e}\u{436}\u{43d}\u{44c}\u{43e}\u{43c}\u{443} \u{440}\u{44f}\u{434}\u{43a}\u{443} \u{43f}\u{43e}\u{432}\u{435}\u{440}\u{442}\u{430}\u{454} \u{43c}\u{438}\u{43d}\u{443}\u{43b}\u{456} \u{43a}\u{43e}\u{43c}\u{430}\u{43d}\u{434}\u{438}.'
,['sp.choose_arg']=
'\u{412}\u{438}\u{431}\u{435}\u{440}\u{456}\u{442}\u{44c} %s \u{43b}\u{456}\u{432}\u{43e}\u{440}\u{443}\u{447}',[
'sp.run']='\u{412}\u{438}\u{43a}\u{43e}\u{43d}\u{430}\u{442}\u{438}',['sp.state_on']=
'\u{423}\u{432}\u{456}\u{43c}\u{43a}\u{43d}\u{435}\u{43d}\u{43e}',['sp.key']=
'\u{41a}\u{43b}\u{430}\u{432}\u{456}\u{448}\u{430}',['sp.no_key']=
'\u{43d}\u{435} \u{43f}\u{440}\u{438}\u{437}\u{43d}\u{430}\u{447}\u{435}\u{43d}\u{430}',['sp.dock']=
'\u{41d}\u{430} \u{434}\u{43e}\u{43a}\u{443}',['sp.also']='\u{422}\u{430}\u{43a}\u{43e}\u{436}',['sp.account']=
'\u{410}\u{43a}\u{430}\u{443}\u{43d}\u{442}',['sp.days']='%d \u{434}\u{43d}.',['sp.team']=
'\u{41a}\u{43e}\u{43c}\u{430}\u{43d}\u{434}\u{430}',['pn.commands']='\u{41a}\u{43e}\u{43c}\u{430}\u{43d}\u{434}\u{438}',
['pn.binds']='\u{411}\u{456}\u{43d}\u{434}\u{438}',['pn.settings']=
'\u{41d}\u{430}\u{43b}\u{430}\u{448}\u{442}\u{443}\u{432}\u{430}\u{43d}\u{43d}\u{44f}',['pn.log']=
'\u{41b}\u{43e}\u{433}',['pn.pins']=
'\u{417}\u{430}\u{43a}\u{440}\u{456}\u{43f}\u{438}\u{442}\u{438} \u{43d}\u{430} \u{434}\u{43e}\u{43a}\u{443}',['bd.new']
='\u{41d}\u{43e}\u{432}\u{438}\u{439} \u{431}\u{456}\u{43d}\u{434}',['bd.command']=
'\u{41a}\u{43e}\u{43c}\u{430}\u{43d}\u{434}\u{430}',['bd.key']='\u{41a}\u{43b}\u{430}\u{432}\u{456}\u{448}\u{430}',[
'bd.mode']='\u{421}\u{43f}\u{440}\u{430}\u{446}\u{44c}\u{43e}\u{432}\u{443}\u{454}',['bd.press']=
'\u{43d}\u{430}\u{442}\u{438}\u{441}\u{43a}\u{430}\u{43d}\u{43d}\u{44f}',['bd.hold']=
'\u{443}\u{442}\u{440}\u{438}\u{43c}\u{430}\u{43d}\u{43d}\u{44f}',['bd.add']=
'\u{414}\u{43e}\u{434}\u{430}\u{442}\u{438}',['bd.empty']=
'\u{411}\u{456}\u{43d}\u{434}\u{456}\u{432} \u{43f}\u{43e}\u{43a}\u{438} \u{43d}\u{435}\u{43c}\u{430}\u{454}',['bd.need'
]=
'\u{421}\u{43f}\u{43e}\u{447}\u{430}\u{442}\u{43a}\u{443} \u{432}\u{432}\u{435}\u{434}\u{456}\u{442}\u{44c} \u{43a}\u{43e}\u{43c}\u{430}\u{43d}\u{434}\u{443} \u{439} \u{43d}\u{430}\u{442}\u{438}\u{441}\u{43d}\u{456}\u{442}\u{44c} \u{43a}\u{43b}\u{430}\u{432}\u{456}\u{448}\u{443}'
,['bd.hold_tag']='\u{443}\u{442}\u{440}\u{438}\u{43c}.',['st.lang']='\u{41c}\u{43e}\u{432}\u{430}',['st.keys']=
'\u{41a}\u{43b}\u{430}\u{432}\u{456}\u{448}\u{456}',['st.bar_key']=
'\u{420}\u{44f}\u{434}\u{43e}\u{43a} \u{43a}\u{43e}\u{43c}\u{430}\u{43d}\u{434}',['st.hide_key']=
'\u{421}\u{445}\u{43e}\u{432}\u{430}\u{442}\u{438} / \u{43f}\u{43e}\u{43a}\u{430}\u{437}\u{430}\u{442}\u{438} TZAR',[
'st.behavior']='\u{41f}\u{43e}\u{432}\u{435}\u{434}\u{456}\u{43d}\u{43a}\u{430}',['st.chat']=
'\u{41a}\u{43e}\u{43c}\u{430}\u{43d}\u{434}\u{438} \u{437} \u{447}\u{430}\u{442}\u{443}',['st.sound']=
'\u{417}\u{432}\u{443}\u{43a} \u{441}\u{43f}\u{43e}\u{432}\u{456}\u{449}\u{435}\u{43d}\u{44c}',['st.log']=
'\u{41b}\u{43e}\u{433}',['st.errors']={'%d \u{43f}\u{43e}\u{43c}\u{438}\u{43b}\u{43a}\u{430}',
'%d \u{43f}\u{43e}\u{43c}\u{438}\u{43b}\u{43a}\u{438}','%d \u{43f}\u{43e}\u{43c}\u{438}\u{43b}\u{43e}\u{43a}'},[
'st.unload']='\u{412}\u{438}\u{43c}\u{43a}\u{43d}\u{443}\u{442}\u{438} TZAR',['dk.default']=
'\u{437}\u{430} \u{437}\u{430}\u{43c}\u{43e}\u{432}\u{447}. %s',['dk.reset']=
'\u{421}\u{43a}\u{438}\u{43d}\u{443}\u{442}\u{438}',['dk.type']=
'\u{412}\u{432}\u{435}\u{441}\u{442}\u{438} \u{447}\u{438}\u{441}\u{43b}\u{43e}',['dk.done']=
'\u{413}\u{43e}\u{442}\u{43e}\u{432}\u{43e}',['nt.title']='TZAR Admin \u{433}\u{43e}\u{442}\u{43e}\u{432}\u{438}\u{439}'
,['nt.pc']=
'%s \u{2014} \u{440}\u{44f}\u{434}\u{43e}\u{43a} \u{43a}\u{43e}\u{43c}\u{430}\u{43d}\u{434} \u{b7} %s \u{2014} \u{441}\u{445}\u{43e}\u{432}\u{430}\u{442}\u{438} TZAR'
,['nt.touch']=
'\u{41a}\u{43d}\u{43e}\u{43f}\u{43a}\u{430} T \u{432}\u{456}\u{434}\u{43a}\u{440}\u{438}\u{432}\u{430}\u{454} \u{440}\u{44f}\u{434}\u{43e}\u{43a} \u{43a}\u{43e}\u{43c}\u{430}\u{43d}\u{434}. \u{423}\u{442}\u{440}\u{438}\u{43c}\u{430}\u{43d}\u{43d}\u{44f} \u{43a}\u{43d}\u{43e}\u{43f}\u{43a}\u{438} \u{43d}\u{430} \u{434}\u{43e}\u{43a}\u{443} \u{2014} \u{43d}\u{430}\u{43b}\u{430}\u{448}\u{442}\u{443}\u{432}\u{430}\u{43d}\u{43d}\u{44f}.'
},es={['sp.title']='TZAR \u{b7} Comandos',['sp.stats']='%d comandos \u{b7} %d activos',['sp.recent']='Recientes',[
'sp.favorites']='Favoritos',['sp.all']='Todos los comandos por categor\u{ed}a',['sp.players']=
'Jugadores \u{b7} nombre y display name',['sp.k_select']='elegir',['sp.k_complete']='completar',['sp.k_run']='ejecutar',
['sp.k_close']='cerrar',['sp.home_title']='Barra de comandos',['sp.home_text']=
'Empieza a escribir un comando o el nombre de un jugador. Tab completa, \u{2191} en la barra vac\u{ed}a trae l\u{ed}neas anteriores.'
,['sp.choose_arg']='Elige %s a la izquierda',['sp.run']='Ejecutar',['sp.state_on']='Activado',['sp.key']='Tecla',[
'sp.no_key']='sin asignar',['sp.dock']='En el dock',['sp.also']='Tambi\u{e9}n',['sp.account']='Cuenta',['sp.days']=
'%d d\u{ed}as',['sp.team']='Equipo',['pn.commands']='Comandos',['pn.binds']='Atajos',['pn.settings']='Ajustes',['pn.log'
]='Registro',['pn.pins']='Fijar en el dock',['bd.new']='Nuevo atajo',['bd.command']='Comando',['bd.key']='Tecla',[
'bd.mode']='Se activa',['bd.press']='al pulsar',['bd.hold']='mientras se mantiene',['bd.add']='A\u{f1}adir',['bd.empty']
='A\u{fa}n no hay atajos',['bd.need']='Primero escribe un comando y pulsa una tecla',['bd.hold_tag']='mant.',['st.lang']
='Idioma',['st.keys']='Teclas',['st.bar_key']='Barra de comandos',['st.hide_key']='Ocultar / mostrar TZAR',[
'st.behavior']='Comportamiento',['st.chat']='Comandos desde el chat',['st.sound']='Sonido de avisos',['st.log']=
'Registro',['st.errors']={'%d error','%d errores'},['st.unload']='Apagar TZAR',['dk.default']='predet. %s',['dk.reset']=
'Restablecer',['dk.type']='Escribir n\u{fa}mero',['dk.done']='Listo',['nt.title']='TZAR Admin est\u{e1} listo',['nt.pc']
='%s abre la barra de comandos \u{b7} %s oculta TZAR',['nt.touch']=
'El bot\u{f3}n T abre la barra de comandos. Mant\u{e9}n un bot\u{f3}n del dock para ajustarlo.'},pt={['sp.title']=
'TZAR \u{b7} Comandos',['sp.stats']='%d comandos \u{b7} %d ligados',['sp.recent']='Recentes',['sp.favorites']=
'Favoritos',['sp.all']='Todos os comandos por categoria',['sp.players']='Jogadores \u{b7} nome e display name',[
'sp.k_select']='escolher',['sp.k_complete']='completar',['sp.k_run']='executar',['sp.k_close']='fechar',['sp.home_title'
]='Barra de comandos',['sp.home_text']=
'Comece a digitar um comando ou o nome de um jogador. Tab completa, \u{2191} na barra vazia traz linhas anteriores.',[
'sp.choose_arg']='Escolha %s \u{e0} esquerda',['sp.run']='Executar',['sp.state_on']='Ligado',['sp.key']='Tecla',[
'sp.no_key']='n\u{e3}o definida',['sp.dock']='No dock',['sp.also']='Tamb\u{e9}m',['sp.account']='Conta',['sp.days']=
'%d dias',['sp.team']='Time',['pn.commands']='Comandos',['pn.binds']='Atalhos',['pn.settings']='Configura\u{e7}\u{f5}es'
,['pn.log']='Registro',['pn.pins']='Fixar no dock',['bd.new']='Novo atalho',['bd.command']='Comando',['bd.key']='Tecla',
['bd.mode']='Dispara',['bd.press']='ao pressionar',['bd.hold']='enquanto segura',['bd.add']='Adicionar',['bd.empty']=
'Nenhum atalho ainda',['bd.need']='Primeiro digite um comando e pressione uma tecla',['bd.hold_tag']='segurar',[
'st.lang']='Idioma',['st.keys']='Teclas',['st.bar_key']='Barra de comandos',['st.hide_key']='Ocultar / mostrar TZAR',[
'st.behavior']='Comportamento',['st.chat']='Comandos pelo chat',['st.sound']='Som de avisos',['st.log']='Registro',[
'st.errors']={'%d erro','%d erros'},['st.unload']='Desligar TZAR',['dk.default']='padr\u{e3}o %s',['dk.reset']=
'Redefinir',['dk.type']='Digitar n\u{fa}mero',['dk.done']='Pronto',['nt.title']='TZAR Admin pronto',['nt.pc']=
'%s abre a barra de comandos \u{b7} %s oculta o TZAR',['nt.touch']=
'O bot\u{e3}o T abre a barra de comandos. Segure um bot\u{e3}o do dock para ajustar.'},de={['sp.title']=
'TZAR \u{b7} Befehle',['sp.stats']='%d Befehle \u{b7} %d an',['sp.recent']='Zuletzt',['sp.favorites']='Favoriten',[
'sp.all']='Alle Befehle nach Kategorie',['sp.players']='Spieler \u{b7} Name und Anzeigename',['sp.k_select']=
'w\u{e4}hlen',['sp.k_complete']='erg\u{e4}nzen',['sp.k_run']='ausf\u{fc}hren',['sp.k_close']='schlie\u{df}en',[
'sp.home_title']='Befehlszeile',['sp.home_text']=
'Tippe einen Befehl oder einen Spielernamen. Tab erg\u{e4}nzt, \u{2191} in der leeren Zeile holt fr\u{fc}here Befehle zur\u{fc}ck.'
,['sp.choose_arg']='W\u{e4}hle links %s',['sp.run']='Ausf\u{fc}hren',['sp.state_on']='An',['sp.key']='Taste',[
'sp.no_key']='nicht belegt',['sp.dock']='Im Dock',['sp.also']='Auch',['sp.account']='Konto',['sp.days']='%d Tage',[
'sp.team']='Team',['pn.commands']='Befehle',['pn.binds']='Tasten',['pn.settings']='Einstellungen',['pn.log']='Protokoll'
,['pn.pins']='Ins Dock heften',['bd.new']='Neue Belegung',['bd.command']='Befehl',['bd.key']='Taste',['bd.mode']=
'Ausl\u{f6}ser',['bd.press']='beim Dr\u{fc}cken',['bd.hold']='beim Halten',['bd.add']='Hinzuf\u{fc}gen',['bd.empty']=
'Noch keine Belegungen',['bd.need']='Erst einen Befehl eingeben und eine Taste dr\u{fc}cken',['bd.hold_tag']='halten',[
'st.lang']='Sprache',['st.keys']='Tasten',['st.bar_key']='Befehlszeile',['st.hide_key']='TZAR aus- / einblenden',[
'st.behavior']='Verhalten',['st.chat']='Befehle aus dem Chat',['st.sound']='Benachrichtigungston',['st.log']='Protokoll'
,['st.errors']={'%d Fehler','%d Fehler'},['st.unload']='TZAR ausschalten',['dk.default']='Standard %s',['dk.reset']=
'Zur\u{fc}cksetzen',['dk.type']='Zahl eingeben',['dk.done']='Fertig',['nt.title']='TZAR Admin ist bereit',['nt.pc']=
'%s \u{f6}ffnet die Befehlszeile \u{b7} %s blendet TZAR aus',['nt.touch']=
'Die T-Taste \u{f6}ffnet die Befehlszeile. Halte eine Dock-Taste, um sie einzustellen.'}}return bundle end function
__DARKLUA_BUNDLE_MODULES.T()local v=__DARKLUA_BUNDLE_MODULES.cache.T if not v then v={c=__modImpl()}
__DARKLUA_BUNDLE_MODULES.cache.T=v end return v.c end end do local function __modImpl()local Types=
__DARKLUA_BUNDLE_MODULES.c()local bundle={en={['c.wear']='Wear avatar',['d.wear']=
[[Wear another player's avatar: someone in this server as they look here, or any username / user id from their profile. Only you see it.]]
,['c.outfit']='Wear outfit',['d.outfit']='Wear one of your saved outfits. Only you see it.',['c.bundle']='Wear bundle',[
'd.bundle']=[[Wear a body bundle from the catalog by its id. Only you see it.]],['c.saveoutfit']='Save outfit',[
'd.saveoutfit']='Save what you are wearing now as an outfit.',['c.renameoutfit']='Rename outfit',['d.renameoutfit']=
'Give a saved outfit a new name.',['c.deloutfit']='Delete outfit',['d.deloutfit']='Delete a saved outfit.',['c.outfits']
='Outfits',['d.outfits']='List your saved outfits.',['c.exportoutfit']='Export outfit',['d.exportoutfit']=
[[Make an autoexec script that wears the outfit on every join.]],['c.avatarrules']='Game avatar rules',['d.avatarrules']
=[[Fit worn looks to this game's avatar rules: scales, forced parts, accessory sizes.]],['c.emote']='Play emote',[
'd.emote']=[[Play an emote from your wheel or by its id. R15 only; everyone sees it.]],['c.addemote']='Add emote',[
'd.addemote']='Add an emote to your wheel by its catalog id.',['c.delemote']='Remove emote',['d.delemote']=
'Take an emote off your wheel.',['c.emotes']='Emotes',['d.emotes']='List the emotes on your wheel.',['av.no_character']=
'Your character is not loaded yet',['av.no_character_of']='%s has no character right now',['av.not_found']=
'No Roblox user \u{201c}%s\u{201d}',['av.avatar_failed']='Could not load the avatar of %s',['av.bundle_bad']=
'No body bundle \u{201c}%s\u{201d}',['av.outfit_saved']='Outfit saved: %s',['av.outfit_renamed']='Outfit %s is now %s',[
'av.outfit_deleted']='Outfit deleted: %s',['av.outfits_none']='No saved outfits yet. Save one with saveoutfit <name>.',[
'av.outfits_list']='Outfits: %s',['av.exported']='Copied, and saved to %s',['av.exported_file']='Saved to %s',[
'av.export_failed']='Could not save or copy the script',['av.export_bad']='This outfit script is damaged',['av.r15_only'
]='Emotes need an R15 character',['av.emote_failed']='Could not load emote %s',['av.not_emote']=
'\u{201c}%s\u{201d} is not an emote',['av.asset_missing']='No catalog item %s',['av.emote_added']='Emote added: %s',[
'av.emote_exists']='Already on the wheel: %s',['av.emote_removed']='Emote removed: %s',['av.emotes_none']=
'No emotes yet. Add one with addemote <id>.',['av.emotes_list']='Emotes: %s'},ru={['c.wear']=
'\u{41d}\u{430}\u{434}\u{435}\u{442}\u{44c} \u{430}\u{432}\u{430}\u{442}\u{430}\u{440}',['d.wear']=
'\u{41d}\u{430}\u{434}\u{435}\u{442}\u{44c} \u{430}\u{432}\u{430}\u{442}\u{430}\u{440} \u{434}\u{440}\u{443}\u{433}\u{43e}\u{433}\u{43e} \u{438}\u{433}\u{440}\u{43e}\u{43a}\u{430}: \u{441} \u{44d}\u{442}\u{43e}\u{433}\u{43e} \u{441}\u{435}\u{440}\u{432}\u{435}\u{440}\u{430}, \u{43a}\u{430}\u{43a} \u{43e}\u{43d} \u{432}\u{44b}\u{433}\u{43b}\u{44f}\u{434}\u{438}\u{442} \u{437}\u{434}\u{435}\u{441}\u{44c}, \u{438}\u{43b}\u{438} \u{43b}\u{44e}\u{431}\u{43e}\u{439} \u{43d}\u{438}\u{43a} / ID \u{438}\u{437} \u{43f}\u{440}\u{43e}\u{444}\u{438}\u{43b}\u{44f}. \u{412}\u{438}\u{434}\u{438}\u{448}\u{44c} \u{442}\u{43e}\u{43b}\u{44c}\u{43a}\u{43e} \u{442}\u{44b}.'
,['c.outfit']='\u{41d}\u{430}\u{434}\u{435}\u{442}\u{44c} \u{43e}\u{431}\u{440}\u{430}\u{437}',['d.outfit']=
'\u{41d}\u{430}\u{434}\u{435}\u{442}\u{44c} \u{43e}\u{434}\u{438}\u{43d} \u{438}\u{437} \u{441}\u{43e}\u{445}\u{440}\u{430}\u{43d}\u{451}\u{43d}\u{43d}\u{44b}\u{445} \u{43e}\u{431}\u{440}\u{430}\u{437}\u{43e}\u{432}. \u{412}\u{438}\u{434}\u{438}\u{448}\u{44c} \u{442}\u{43e}\u{43b}\u{44c}\u{43a}\u{43e} \u{442}\u{44b}.'
,['c.bundle']='\u{41d}\u{430}\u{434}\u{435}\u{442}\u{44c} \u{431}\u{430}\u{43d}\u{434}\u{43b}',['d.bundle']=
'\u{41d}\u{430}\u{434}\u{435}\u{442}\u{44c} \u{442}\u{435}\u{43b}\u{43e}-\u{431}\u{430}\u{43d}\u{434}\u{43b} \u{438}\u{437} \u{43a}\u{430}\u{442}\u{430}\u{43b}\u{43e}\u{433}\u{430} \u{43f}\u{43e} \u{435}\u{433}\u{43e} ID. \u{412}\u{438}\u{434}\u{438}\u{448}\u{44c} \u{442}\u{43e}\u{43b}\u{44c}\u{43a}\u{43e} \u{442}\u{44b}.'
,['c.saveoutfit']='\u{421}\u{43e}\u{445}\u{440}\u{430}\u{43d}\u{438}\u{442}\u{44c} \u{43e}\u{431}\u{440}\u{430}\u{437}',
['d.saveoutfit']=
'\u{421}\u{43e}\u{445}\u{440}\u{430}\u{43d}\u{438}\u{442}\u{44c} \u{442}\u{43e}, \u{447}\u{442}\u{43e} \u{43d}\u{430} \u{442}\u{435}\u{431}\u{435} \u{441}\u{435}\u{439}\u{447}\u{430}\u{441}, \u{43a}\u{430}\u{43a} \u{43e}\u{431}\u{440}\u{430}\u{437}.'
,['c.renameoutfit']=
'\u{41f}\u{435}\u{440}\u{435}\u{438}\u{43c}\u{435}\u{43d}\u{43e}\u{432}\u{430}\u{442}\u{44c} \u{43e}\u{431}\u{440}\u{430}\u{437}'
,['d.renameoutfit']=
'\u{414}\u{430}\u{442}\u{44c} \u{441}\u{43e}\u{445}\u{440}\u{430}\u{43d}\u{451}\u{43d}\u{43d}\u{43e}\u{43c}\u{443} \u{43e}\u{431}\u{440}\u{430}\u{437}\u{443} \u{43d}\u{43e}\u{432}\u{43e}\u{435} \u{438}\u{43c}\u{44f}.'
,['c.deloutfit']='\u{423}\u{434}\u{430}\u{43b}\u{438}\u{442}\u{44c} \u{43e}\u{431}\u{440}\u{430}\u{437}',['d.deloutfit']
=
'\u{423}\u{434}\u{430}\u{43b}\u{438}\u{442}\u{44c} \u{441}\u{43e}\u{445}\u{440}\u{430}\u{43d}\u{451}\u{43d}\u{43d}\u{44b}\u{439} \u{43e}\u{431}\u{440}\u{430}\u{437}.'
,['c.outfits']='\u{41e}\u{431}\u{440}\u{430}\u{437}\u{44b}',['d.outfits']=
'\u{421}\u{43f}\u{438}\u{441}\u{43e}\u{43a} \u{441}\u{43e}\u{445}\u{440}\u{430}\u{43d}\u{451}\u{43d}\u{43d}\u{44b}\u{445} \u{43e}\u{431}\u{440}\u{430}\u{437}\u{43e}\u{432}.'
,['c.exportoutfit']='\u{42d}\u{43a}\u{441}\u{43f}\u{43e}\u{440}\u{442} \u{43e}\u{431}\u{440}\u{430}\u{437}\u{430}',[
'd.exportoutfit']=
'\u{421}\u{434}\u{435}\u{43b}\u{430}\u{442}\u{44c} autoexec-\u{441}\u{43a}\u{440}\u{438}\u{43f}\u{442}, \u{43a}\u{43e}\u{442}\u{43e}\u{440}\u{44b}\u{439} \u{43d}\u{430}\u{434}\u{435}\u{432}\u{430}\u{435}\u{442} \u{43e}\u{431}\u{440}\u{430}\u{437} \u{43f}\u{440}\u{438} \u{43a}\u{430}\u{436}\u{434}\u{43e}\u{43c} \u{432}\u{445}\u{43e}\u{434}\u{435}.'
,['c.avatarrules']=
'\u{41f}\u{440}\u{430}\u{432}\u{438}\u{43b}\u{430} \u{430}\u{432}\u{430}\u{442}\u{430}\u{440}\u{430} \u{438}\u{433}\u{440}\u{44b}'
,['d.avatarrules']=
'\u{41f}\u{43e}\u{434}\u{433}\u{43e}\u{43d}\u{44f}\u{442}\u{44c} \u{43d}\u{430}\u{434}\u{435}\u{442}\u{43e}\u{435} \u{43f}\u{43e}\u{434} \u{43f}\u{440}\u{430}\u{432}\u{438}\u{43b}\u{430} \u{44d}\u{442}\u{43e}\u{439} \u{438}\u{433}\u{440}\u{44b}: \u{43c}\u{430}\u{441}\u{448}\u{442}\u{430}\u{431}\u{44b}, \u{43e}\u{431}\u{44f}\u{437}\u{430}\u{442}\u{435}\u{43b}\u{44c}\u{43d}\u{44b}\u{435} \u{447}\u{430}\u{441}\u{442}\u{438}, \u{440}\u{430}\u{437}\u{43c}\u{435}\u{440} \u{430}\u{43a}\u{441}\u{435}\u{441}\u{441}\u{443}\u{430}\u{440}\u{43e}\u{432}.'
,['c.emote']='\u{42d}\u{43c}\u{43e}\u{446}\u{438}\u{44f}',['d.emote']=
'\u{421}\u{44b}\u{433}\u{440}\u{430}\u{442}\u{44c} \u{44d}\u{43c}\u{43e}\u{446}\u{438}\u{44e} \u{441} \u{43a}\u{43e}\u{43b}\u{435}\u{441}\u{430} \u{438}\u{43b}\u{438} \u{43f}\u{43e} ID. \u{422}\u{43e}\u{43b}\u{44c}\u{43a}\u{43e} R15; \u{432}\u{438}\u{434}\u{44f}\u{442} \u{432}\u{441}\u{435}.'
,['c.addemote']='\u{414}\u{43e}\u{431}\u{430}\u{432}\u{438}\u{442}\u{44c} \u{44d}\u{43c}\u{43e}\u{446}\u{438}\u{44e}',[
'd.addemote']=
'\u{414}\u{43e}\u{431}\u{430}\u{432}\u{438}\u{442}\u{44c} \u{44d}\u{43c}\u{43e}\u{446}\u{438}\u{44e} \u{43d}\u{430} \u{43a}\u{43e}\u{43b}\u{435}\u{441}\u{43e} \u{43f}\u{43e} ID \u{438}\u{437} \u{43a}\u{430}\u{442}\u{430}\u{43b}\u{43e}\u{433}\u{430}.'
,['c.delemote']='\u{423}\u{431}\u{440}\u{430}\u{442}\u{44c} \u{44d}\u{43c}\u{43e}\u{446}\u{438}\u{44e}',['d.delemote']=
'\u{423}\u{431}\u{440}\u{430}\u{442}\u{44c} \u{44d}\u{43c}\u{43e}\u{446}\u{438}\u{44e} \u{441} \u{43a}\u{43e}\u{43b}\u{435}\u{441}\u{430}.'
,['c.emotes']='\u{42d}\u{43c}\u{43e}\u{446}\u{438}\u{438}',['d.emotes']=
'\u{421}\u{43f}\u{438}\u{441}\u{43e}\u{43a} \u{44d}\u{43c}\u{43e}\u{446}\u{438}\u{439} \u{43d}\u{430} \u{43a}\u{43e}\u{43b}\u{435}\u{441}\u{435}.'
,['av.no_character']=
'\u{41f}\u{435}\u{440}\u{441}\u{43e}\u{43d}\u{430}\u{436} \u{435}\u{449}\u{451} \u{43d}\u{435} \u{437}\u{430}\u{433}\u{440}\u{443}\u{437}\u{438}\u{43b}\u{441}\u{44f}'
,['av.no_character_of']=
'\u{423} %s \u{441}\u{435}\u{439}\u{447}\u{430}\u{441} \u{43d}\u{435}\u{442} \u{43f}\u{435}\u{440}\u{441}\u{43e}\u{43d}\u{430}\u{436}\u{430}'
,['av.not_found']=
'\u{41d}\u{435}\u{442} \u{43f}\u{43e}\u{43b}\u{44c}\u{437}\u{43e}\u{432}\u{430}\u{442}\u{435}\u{43b}\u{44f} Roblox \u{ab}%s\u{bb}'
,['av.avatar_failed']=
'\u{41d}\u{435} \u{443}\u{434}\u{430}\u{43b}\u{43e}\u{441}\u{44c} \u{437}\u{430}\u{433}\u{440}\u{443}\u{437}\u{438}\u{442}\u{44c} \u{430}\u{432}\u{430}\u{442}\u{430}\u{440} %s'
,['av.bundle_bad']=
'\u{41d}\u{435}\u{442} \u{442}\u{435}\u{43b}\u{430}-\u{431}\u{430}\u{43d}\u{434}\u{43b}\u{430} \u{ab}%s\u{bb}',[
'av.outfit_saved']='\u{41e}\u{431}\u{440}\u{430}\u{437} \u{441}\u{43e}\u{445}\u{440}\u{430}\u{43d}\u{451}\u{43d}: %s',[
'av.outfit_renamed']=
'\u{41e}\u{431}\u{440}\u{430}\u{437} %s \u{442}\u{435}\u{43f}\u{435}\u{440}\u{44c} \u{43d}\u{430}\u{437}\u{44b}\u{432}\u{430}\u{435}\u{442}\u{441}\u{44f} %s'
,['av.outfit_deleted']='\u{41e}\u{431}\u{440}\u{430}\u{437} \u{443}\u{434}\u{430}\u{43b}\u{451}\u{43d}: %s',[
'av.outfits_none']=
'\u{421}\u{43e}\u{445}\u{440}\u{430}\u{43d}\u{451}\u{43d}\u{43d}\u{44b}\u{445} \u{43e}\u{431}\u{440}\u{430}\u{437}\u{43e}\u{432} \u{43f}\u{43e}\u{43a}\u{430} \u{43d}\u{435}\u{442}. \u{421}\u{43e}\u{445}\u{440}\u{430}\u{43d}\u{438}: saveoutfit <\u{438}\u{43c}\u{44f}>.'
,['av.outfits_list']='\u{41e}\u{431}\u{440}\u{430}\u{437}\u{44b}: %s',['av.exported']=
'\u{421}\u{43a}\u{43e}\u{43f}\u{438}\u{440}\u{43e}\u{432}\u{430}\u{43d}\u{43e} \u{438} \u{441}\u{43e}\u{445}\u{440}\u{430}\u{43d}\u{435}\u{43d}\u{43e} \u{432} %s'
,['av.exported_file']='\u{421}\u{43e}\u{445}\u{440}\u{430}\u{43d}\u{435}\u{43d}\u{43e} \u{432} %s',['av.export_failed']=
'\u{41d}\u{435} \u{443}\u{434}\u{430}\u{43b}\u{43e}\u{441}\u{44c} \u{43d}\u{438} \u{441}\u{43e}\u{445}\u{440}\u{430}\u{43d}\u{438}\u{442}\u{44c}, \u{43d}\u{438} \u{441}\u{43a}\u{43e}\u{43f}\u{438}\u{440}\u{43e}\u{432}\u{430}\u{442}\u{44c} \u{441}\u{43a}\u{440}\u{438}\u{43f}\u{442}'
,['av.export_bad']=
'\u{421}\u{43a}\u{440}\u{438}\u{43f}\u{442} \u{43e}\u{431}\u{440}\u{430}\u{437}\u{430} \u{43f}\u{43e}\u{432}\u{440}\u{435}\u{436}\u{434}\u{451}\u{43d}'
,['av.r15_only']=
'\u{42d}\u{43c}\u{43e}\u{446}\u{438}\u{438} \u{440}\u{430}\u{431}\u{43e}\u{442}\u{430}\u{44e}\u{442} \u{442}\u{43e}\u{43b}\u{44c}\u{43a}\u{43e} \u{43d}\u{430} R15'
,['av.emote_failed']=
'\u{41d}\u{435} \u{443}\u{434}\u{430}\u{43b}\u{43e}\u{441}\u{44c} \u{437}\u{430}\u{433}\u{440}\u{443}\u{437}\u{438}\u{442}\u{44c} \u{44d}\u{43c}\u{43e}\u{446}\u{438}\u{44e} %s'
,['av.not_emote']=
'\u{ab}%s\u{bb} \u{2014} \u{44d}\u{442}\u{43e} \u{43d}\u{435} \u{44d}\u{43c}\u{43e}\u{446}\u{438}\u{44f}',[
'av.asset_missing']=
'\u{412} \u{43a}\u{430}\u{442}\u{430}\u{43b}\u{43e}\u{433}\u{435} \u{43d}\u{435}\u{442} \u{43f}\u{440}\u{435}\u{434}\u{43c}\u{435}\u{442}\u{430} %s'
,['av.emote_added']=
'\u{42d}\u{43c}\u{43e}\u{446}\u{438}\u{44f} \u{434}\u{43e}\u{431}\u{430}\u{432}\u{43b}\u{435}\u{43d}\u{430}: %s',[
'av.emote_exists']='\u{423}\u{436}\u{435} \u{43d}\u{430} \u{43a}\u{43e}\u{43b}\u{435}\u{441}\u{435}: %s',[
'av.emote_removed']='\u{42d}\u{43c}\u{43e}\u{446}\u{438}\u{44f} \u{443}\u{431}\u{440}\u{430}\u{43d}\u{430}: %s',[
'av.emotes_none']=
'\u{42d}\u{43c}\u{43e}\u{446}\u{438}\u{439} \u{43f}\u{43e}\u{43a}\u{430} \u{43d}\u{435}\u{442}. \u{414}\u{43e}\u{431}\u{430}\u{432}\u{44c}: addemote <id>.'
,['av.emotes_list']='\u{42d}\u{43c}\u{43e}\u{446}\u{438}\u{438}: %s'},uk={['c.wear']=
'\u{412}\u{434}\u{44f}\u{433}\u{43d}\u{443}\u{442}\u{438} \u{430}\u{432}\u{430}\u{442}\u{430}\u{440}',['d.wear']=
'\u{412}\u{434}\u{44f}\u{433}\u{43d}\u{443}\u{442}\u{438} \u{430}\u{432}\u{430}\u{442}\u{430}\u{440} \u{456}\u{43d}\u{448}\u{43e}\u{433}\u{43e} \u{433}\u{440}\u{430}\u{432}\u{446}\u{44f}: \u{437} \u{446}\u{44c}\u{43e}\u{433}\u{43e} \u{441}\u{435}\u{440}\u{432}\u{435}\u{440}\u{430}, \u{44f}\u{43a}\u{438}\u{43c} \u{432}\u{456}\u{43d} \u{454} \u{442}\u{443}\u{442}, \u{430}\u{431}\u{43e} \u{431}\u{443}\u{434}\u{44c}-\u{44f}\u{43a}\u{438}\u{439} \u{43d}\u{456}\u{43a} / ID \u{437} \u{43f}\u{440}\u{43e}\u{444}\u{456}\u{43b}\u{44e}. \u{411}\u{430}\u{447}\u{438}\u{448} \u{43b}\u{438}\u{448}\u{435} \u{442}\u{438}.'
,['c.outfit']='\u{412}\u{434}\u{44f}\u{433}\u{43d}\u{443}\u{442}\u{438} \u{43e}\u{431}\u{440}\u{430}\u{437}',['d.outfit'
]=
'\u{412}\u{434}\u{44f}\u{433}\u{43d}\u{443}\u{442}\u{438} \u{43e}\u{434}\u{438}\u{43d} \u{437}\u{456} \u{437}\u{431}\u{435}\u{440}\u{435}\u{436}\u{435}\u{43d}\u{438}\u{445} \u{43e}\u{431}\u{440}\u{430}\u{437}\u{456}\u{432}. \u{411}\u{430}\u{447}\u{438}\u{448} \u{43b}\u{438}\u{448}\u{435} \u{442}\u{438}.'
,['c.bundle']='\u{412}\u{434}\u{44f}\u{433}\u{43d}\u{443}\u{442}\u{438} \u{431}\u{430}\u{43d}\u{434}\u{43b}',['d.bundle'
]=
'\u{412}\u{434}\u{44f}\u{433}\u{43d}\u{443}\u{442}\u{438} \u{442}\u{456}\u{43b}\u{43e}-\u{431}\u{430}\u{43d}\u{434}\u{43b} \u{437} \u{43a}\u{430}\u{442}\u{430}\u{43b}\u{43e}\u{433}\u{443} \u{437}\u{430} \u{439}\u{43e}\u{433}\u{43e} ID. \u{411}\u{430}\u{447}\u{438}\u{448} \u{43b}\u{438}\u{448}\u{435} \u{442}\u{438}.'
,['c.saveoutfit']='\u{417}\u{431}\u{435}\u{440}\u{435}\u{433}\u{442}\u{438} \u{43e}\u{431}\u{440}\u{430}\u{437}',[
'd.saveoutfit']=
'\u{417}\u{431}\u{435}\u{440}\u{435}\u{433}\u{442}\u{438} \u{442}\u{435}, \u{449}\u{43e} \u{43d}\u{430} \u{442}\u{43e}\u{431}\u{456} \u{437}\u{430}\u{440}\u{430}\u{437}, \u{44f}\u{43a} \u{43e}\u{431}\u{440}\u{430}\u{437}.'
,['c.renameoutfit']=
'\u{41f}\u{435}\u{440}\u{435}\u{439}\u{43c}\u{435}\u{43d}\u{443}\u{432}\u{430}\u{442}\u{438} \u{43e}\u{431}\u{440}\u{430}\u{437}'
,['d.renameoutfit']=
'\u{414}\u{430}\u{442}\u{438} \u{437}\u{431}\u{435}\u{440}\u{435}\u{436}\u{435}\u{43d}\u{43e}\u{43c}\u{443} \u{43e}\u{431}\u{440}\u{430}\u{437}\u{443} \u{43d}\u{43e}\u{432}\u{443} \u{43d}\u{430}\u{437}\u{432}\u{443}.'
,['c.deloutfit']='\u{412}\u{438}\u{434}\u{430}\u{43b}\u{438}\u{442}\u{438} \u{43e}\u{431}\u{440}\u{430}\u{437}',[
'd.deloutfit']=
'\u{412}\u{438}\u{434}\u{430}\u{43b}\u{438}\u{442}\u{438} \u{437}\u{431}\u{435}\u{440}\u{435}\u{436}\u{435}\u{43d}\u{438}\u{439} \u{43e}\u{431}\u{440}\u{430}\u{437}.'
,['c.outfits']='\u{41e}\u{431}\u{440}\u{430}\u{437}\u{438}',['d.outfits']=
'\u{421}\u{43f}\u{438}\u{441}\u{43e}\u{43a} \u{437}\u{431}\u{435}\u{440}\u{435}\u{436}\u{435}\u{43d}\u{438}\u{445} \u{43e}\u{431}\u{440}\u{430}\u{437}\u{456}\u{432}.'
,['c.exportoutfit']='\u{415}\u{43a}\u{441}\u{43f}\u{43e}\u{440}\u{442} \u{43e}\u{431}\u{440}\u{430}\u{437}\u{443}',[
'd.exportoutfit']=
'\u{417}\u{440}\u{43e}\u{431}\u{438}\u{442}\u{438} autoexec-\u{441}\u{43a}\u{440}\u{438}\u{43f}\u{442}, \u{44f}\u{43a}\u{438}\u{439} \u{432}\u{434}\u{44f}\u{433}\u{430}\u{454} \u{43e}\u{431}\u{440}\u{430}\u{437} \u{43f}\u{440}\u{438} \u{43a}\u{43e}\u{436}\u{43d}\u{43e}\u{43c}\u{443} \u{432}\u{445}\u{43e}\u{434}\u{456}.'
,['c.avatarrules']=
'\u{41f}\u{440}\u{430}\u{432}\u{438}\u{43b}\u{430} \u{430}\u{432}\u{430}\u{442}\u{430}\u{440}\u{430} \u{433}\u{440}\u{438}'
,['d.avatarrules']=
"\u{41f}\u{456}\u{434}\u{433}\u{430}\u{43d}\u{44f}\u{442}\u{438} \u{432}\u{434}\u{44f}\u{433}\u{43d}\u{443}\u{442}\u{435} \u{43f}\u{456}\u{434} \u{43f}\u{440}\u{430}\u{432}\u{438}\u{43b}\u{430} \u{446}\u{456}\u{454}\u{457} \u{433}\u{440}\u{438}: \u{43c}\u{430}\u{441}\u{448}\u{442}\u{430}\u{431}\u{438}, \u{43e}\u{431}\u{43e}\u{432}'\u{44f}\u{437}\u{43a}\u{43e}\u{432}\u{456} \u{447}\u{430}\u{441}\u{442}\u{438}\u{43d}\u{438}, \u{440}\u{43e}\u{437}\u{43c}\u{456}\u{440} \u{430}\u{43a}\u{441}\u{435}\u{441}\u{443}\u{430}\u{440}\u{456}\u{432}."
,['c.emote']='\u{415}\u{43c}\u{43e}\u{446}\u{456}\u{44f}',['d.emote']=
'\u{417}\u{456}\u{433}\u{440}\u{430}\u{442}\u{438} \u{435}\u{43c}\u{43e}\u{446}\u{456}\u{44e} \u{437} \u{43a}\u{43e}\u{43b}\u{435}\u{441}\u{430} \u{430}\u{431}\u{43e} \u{437}\u{430} ID. \u{41b}\u{438}\u{448}\u{435} R15; \u{431}\u{430}\u{447}\u{430}\u{442}\u{44c} \u{443}\u{441}\u{456}.'
,['c.addemote']='\u{414}\u{43e}\u{434}\u{430}\u{442}\u{438} \u{435}\u{43c}\u{43e}\u{446}\u{456}\u{44e}',['d.addemote']=
'\u{414}\u{43e}\u{434}\u{430}\u{442}\u{438} \u{435}\u{43c}\u{43e}\u{446}\u{456}\u{44e} \u{43d}\u{430} \u{43a}\u{43e}\u{43b}\u{435}\u{441}\u{43e} \u{437}\u{430} ID \u{437} \u{43a}\u{430}\u{442}\u{430}\u{43b}\u{43e}\u{433}\u{443}.'
,['c.delemote']='\u{41f}\u{440}\u{438}\u{431}\u{440}\u{430}\u{442}\u{438} \u{435}\u{43c}\u{43e}\u{446}\u{456}\u{44e}',[
'd.delemote']=
'\u{41f}\u{440}\u{438}\u{431}\u{440}\u{430}\u{442}\u{438} \u{435}\u{43c}\u{43e}\u{446}\u{456}\u{44e} \u{437} \u{43a}\u{43e}\u{43b}\u{435}\u{441}\u{430}.'
,['c.emotes']='\u{415}\u{43c}\u{43e}\u{446}\u{456}\u{457}',['d.emotes']=
'\u{421}\u{43f}\u{438}\u{441}\u{43e}\u{43a} \u{435}\u{43c}\u{43e}\u{446}\u{456}\u{439} \u{43d}\u{430} \u{43a}\u{43e}\u{43b}\u{435}\u{441}\u{456}.'
,['av.no_character']=
'\u{41f}\u{435}\u{440}\u{441}\u{43e}\u{43d}\u{430}\u{436} \u{449}\u{435} \u{43d}\u{435} \u{437}\u{430}\u{432}\u{430}\u{43d}\u{442}\u{430}\u{436}\u{438}\u{432}\u{441}\u{44f}'
,['av.no_character_of']=
'\u{423} %s \u{437}\u{430}\u{440}\u{430}\u{437} \u{43d}\u{435}\u{43c}\u{430}\u{454} \u{43f}\u{435}\u{440}\u{441}\u{43e}\u{43d}\u{430}\u{436}\u{430}'
,['av.not_found']=
'\u{41d}\u{435}\u{43c}\u{430}\u{454} \u{43a}\u{43e}\u{440}\u{438}\u{441}\u{442}\u{443}\u{432}\u{430}\u{447}\u{430} Roblox \u{ab}%s\u{bb}'
,['av.avatar_failed']=
'\u{41d}\u{435} \u{432}\u{434}\u{430}\u{43b}\u{43e}\u{441}\u{44f} \u{437}\u{430}\u{432}\u{430}\u{43d}\u{442}\u{430}\u{436}\u{438}\u{442}\u{438} \u{430}\u{432}\u{430}\u{442}\u{430}\u{440} %s'
,['av.bundle_bad']=
'\u{41d}\u{435}\u{43c}\u{430}\u{454} \u{442}\u{456}\u{43b}\u{430}-\u{431}\u{430}\u{43d}\u{434}\u{43b}\u{430} \u{ab}%s\u{bb}'
,['av.outfit_saved']=
'\u{41e}\u{431}\u{440}\u{430}\u{437} \u{437}\u{431}\u{435}\u{440}\u{435}\u{436}\u{435}\u{43d}\u{43e}: %s',[
'av.outfit_renamed']=
'\u{41e}\u{431}\u{440}\u{430}\u{437} %s \u{442}\u{435}\u{43f}\u{435}\u{440} \u{43d}\u{430}\u{437}\u{438}\u{432}\u{430}\u{454}\u{442}\u{44c}\u{441}\u{44f} %s'
,['av.outfit_deleted']=
'\u{41e}\u{431}\u{440}\u{430}\u{437} \u{432}\u{438}\u{434}\u{430}\u{43b}\u{435}\u{43d}\u{43e}: %s',['av.outfits_none']=
'\u{417}\u{431}\u{435}\u{440}\u{435}\u{436}\u{435}\u{43d}\u{438}\u{445} \u{43e}\u{431}\u{440}\u{430}\u{437}\u{456}\u{432} \u{43f}\u{43e}\u{43a}\u{438} \u{43d}\u{435}\u{43c}\u{430}\u{454}. \u{417}\u{431}\u{435}\u{440}\u{435}\u{436}\u{438}: saveoutfit <\u{43d}\u{430}\u{437}\u{432}\u{430}>.'
,['av.outfits_list']='\u{41e}\u{431}\u{440}\u{430}\u{437}\u{438}: %s',['av.exported']=
'\u{421}\u{43a}\u{43e}\u{43f}\u{456}\u{439}\u{43e}\u{432}\u{430}\u{43d}\u{43e} \u{439} \u{437}\u{431}\u{435}\u{440}\u{435}\u{436}\u{435}\u{43d}\u{43e} \u{432} %s'
,['av.exported_file']='\u{417}\u{431}\u{435}\u{440}\u{435}\u{436}\u{435}\u{43d}\u{43e} \u{432} %s',['av.export_failed']=
'\u{41d}\u{435} \u{432}\u{434}\u{430}\u{43b}\u{43e}\u{441}\u{44f} \u{43d}\u{456} \u{437}\u{431}\u{435}\u{440}\u{435}\u{433}\u{442}\u{438}, \u{43d}\u{456} \u{441}\u{43a}\u{43e}\u{43f}\u{456}\u{44e}\u{432}\u{430}\u{442}\u{438} \u{441}\u{43a}\u{440}\u{438}\u{43f}\u{442}'
,['av.export_bad']=
'\u{421}\u{43a}\u{440}\u{438}\u{43f}\u{442} \u{43e}\u{431}\u{440}\u{430}\u{437}\u{443} \u{43f}\u{43e}\u{448}\u{43a}\u{43e}\u{434}\u{436}\u{435}\u{43d}\u{43e}'
,['av.r15_only']=
'\u{415}\u{43c}\u{43e}\u{446}\u{456}\u{457} \u{43f}\u{440}\u{430}\u{446}\u{44e}\u{44e}\u{442}\u{44c} \u{43b}\u{438}\u{448}\u{435} \u{43d}\u{430} R15'
,['av.emote_failed']=
'\u{41d}\u{435} \u{432}\u{434}\u{430}\u{43b}\u{43e}\u{441}\u{44f} \u{437}\u{430}\u{432}\u{430}\u{43d}\u{442}\u{430}\u{436}\u{438}\u{442}\u{438} \u{435}\u{43c}\u{43e}\u{446}\u{456}\u{44e} %s'
,['av.not_emote']='\u{ab}%s\u{bb} \u{2014} \u{446}\u{435} \u{43d}\u{435} \u{435}\u{43c}\u{43e}\u{446}\u{456}\u{44f}',[
'av.asset_missing']=
'\u{423} \u{43a}\u{430}\u{442}\u{430}\u{43b}\u{43e}\u{437}\u{456} \u{43d}\u{435}\u{43c}\u{430}\u{454} \u{43f}\u{440}\u{435}\u{434}\u{43c}\u{435}\u{442}\u{430} %s'
,['av.emote_added']='\u{415}\u{43c}\u{43e}\u{446}\u{456}\u{44e} \u{434}\u{43e}\u{434}\u{430}\u{43d}\u{43e}: %s',[
'av.emote_exists']='\u{412}\u{436}\u{435} \u{43d}\u{430} \u{43a}\u{43e}\u{43b}\u{435}\u{441}\u{456}: %s',[
'av.emote_removed']=
'\u{415}\u{43c}\u{43e}\u{446}\u{456}\u{44e} \u{43f}\u{440}\u{438}\u{431}\u{440}\u{430}\u{43d}\u{43e}: %s',[
'av.emotes_none']=
'\u{415}\u{43c}\u{43e}\u{446}\u{456}\u{439} \u{43f}\u{43e}\u{43a}\u{438} \u{43d}\u{435}\u{43c}\u{430}\u{454}. \u{414}\u{43e}\u{434}\u{430}\u{439}: addemote <id>.'
,['av.emotes_list']='\u{415}\u{43c}\u{43e}\u{446}\u{456}\u{457}: %s'},es={['c.wear']='Usar avatar',['d.wear']=
'Usa el avatar de otro jugador: alguien de este servidor tal como se ve aqu\u{ed}, o cualquier usuario / id desde su perfil. Solo lo ves t\u{fa}.'
,['c.outfit']='Usar atuendo',['d.outfit']='Usa uno de tus atuendos guardados. Solo lo ves t\u{fa}.',['c.bundle']=
'Usar paquete',['d.bundle']='Usa un paquete de cuerpo del cat\u{e1}logo por su id. Solo lo ves t\u{fa}.',['c.saveoutfit'
]='Guardar atuendo',['d.saveoutfit']='Guarda lo que llevas ahora como atuendo.',['c.renameoutfit']='Renombrar atuendo',[
'd.renameoutfit']='Ponle otro nombre a un atuendo guardado.',['c.deloutfit']='Borrar atuendo',['d.deloutfit']=
'Borra un atuendo guardado.',['c.outfits']='Atuendos',['d.outfits']='Lista tus atuendos guardados.',['c.exportoutfit']=
'Exportar atuendo',['d.exportoutfit']=[[Crea un script de autoexec que pone el atuendo en cada entrada.]],[
'c.avatarrules']='Reglas de avatar del juego',['d.avatarrules']=
'Ajusta lo que llevas a las reglas de avatar de este juego: escalas, partes forzadas, tama\u{f1}o de accesorios.',[
'c.emote']='Hacer emote',['d.emote']=[[Haz un emote de tu rueda o por su id. Solo R15; lo ven todos.]],['c.addemote']=
'A\u{f1}adir emote',['d.addemote']='A\u{f1}ade un emote a tu rueda por su id del cat\u{e1}logo.',['c.delemote']=
'Quitar emote',['d.delemote']='Quita un emote de tu rueda.',['c.emotes']='Emotes',['d.emotes']=
'Lista los emotes de tu rueda.',['av.no_character']='Tu personaje a\u{fa}n no ha cargado',['av.no_character_of']=
'%s no tiene personaje ahora mismo',['av.not_found']='No existe el usuario de Roblox \u{ab}%s\u{bb}',['av.avatar_failed'
]='No se pudo cargar el avatar de %s',['av.bundle_bad']='No hay paquete de cuerpo \u{ab}%s\u{bb}',['av.outfit_saved']=
'Atuendo guardado: %s',['av.outfit_renamed']='El atuendo %s ahora se llama %s',['av.outfit_deleted']=
'Atuendo borrado: %s',['av.outfits_none']='A\u{fa}n no hay atuendos. Guarda uno con saveoutfit <nombre>.',[
'av.outfits_list']='Atuendos: %s',['av.exported']='Copiado y guardado en %s',['av.exported_file']='Guardado en %s',[
'av.export_failed']='No se pudo guardar ni copiar el script',['av.export_bad']=
'El script del atuendo est\u{e1} da\u{f1}ado',['av.r15_only']='Los emotes necesitan un personaje R15',['av.emote_failed'
]='No se pudo cargar el emote %s',['av.not_emote']='\u{ab}%s\u{bb} no es un emote',['av.asset_missing']=
'No hay art\u{ed}culo %s en el cat\u{e1}logo',['av.emote_added']='Emote a\u{f1}adido: %s',['av.emote_exists']=
'Ya est\u{e1} en la rueda: %s',['av.emote_removed']='Emote quitado: %s',['av.emotes_none']=
'A\u{fa}n no hay emotes. A\u{f1}ade uno con addemote <id>.',['av.emotes_list']='Emotes: %s'},pt={['c.wear']=
'Vestir avatar',['d.wear']=
'Veste o avatar de outro jogador: algu\u{e9}m deste servidor como est\u{e1} aqui, ou qualquer usu\u{e1}rio / id do perfil. S\u{f3} voc\u{ea} v\u{ea}.'
,['c.outfit']='Vestir visual',['d.outfit']='Veste um dos seus visuais salvos. S\u{f3} voc\u{ea} v\u{ea}.',['c.bundle']=
'Vestir pacote',['d.bundle']='Veste um pacote de corpo do cat\u{e1}logo pelo id. S\u{f3} voc\u{ea} v\u{ea}.',[
'c.saveoutfit']='Salvar visual',['d.saveoutfit']='Salva o que voc\u{ea} est\u{e1} usando agora como visual.',[
'c.renameoutfit']='Renomear visual',['d.renameoutfit']='D\u{e1} outro nome a um visual salvo.',['c.deloutfit']=
'Apagar visual',['d.deloutfit']='Apaga um visual salvo.',['c.outfits']='Visuais',['d.outfits']=
'Lista seus visuais salvos.',['c.exportoutfit']='Exportar visual',['d.exportoutfit']=
[[Cria um script de autoexec que veste o visual a cada entrada.]],['c.avatarrules']='Regras de avatar do jogo',[
'd.avatarrules']=
'Ajusta o que voc\u{ea} veste \u{e0}s regras de avatar deste jogo: escalas, partes obrigat\u{f3}rias, tamanho de acess\u{f3}rios.'
,['c.emote']='Fazer emote',['d.emote']='Faz um emote da sua roda ou pelo id. S\u{f3} R15; todos veem.',['c.addemote']=
'Adicionar emote',['d.addemote']='Adiciona um emote \u{e0} sua roda pelo id do cat\u{e1}logo.',['c.delemote']=
'Tirar emote',['d.delemote']='Tira um emote da sua roda.',['c.emotes']='Emotes',['d.emotes']=
'Lista os emotes da sua roda.',['av.no_character']='Seu personagem ainda n\u{e3}o carregou',['av.no_character_of']=
'%s est\u{e1} sem personagem agora',['av.not_found']='N\u{e3}o existe o usu\u{e1}rio do Roblox \u{201c}%s\u{201d}',[
'av.avatar_failed']='N\u{e3}o deu para carregar o avatar de %s',['av.bundle_bad']=
'N\u{e3}o h\u{e1} pacote de corpo \u{201c}%s\u{201d}',['av.outfit_saved']='Visual salvo: %s',['av.outfit_renamed']=
'O visual %s agora se chama %s',['av.outfit_deleted']='Visual apagado: %s',['av.outfits_none']=
'Nenhum visual salvo ainda. Salve um com saveoutfit <nome>.',['av.outfits_list']='Visuais: %s',['av.exported']=
'Copiado e salvo em %s',['av.exported_file']='Salvo em %s',['av.export_failed']=
'N\u{e3}o deu para salvar nem copiar o script',['av.export_bad']='O script do visual est\u{e1} danificado',[
'av.r15_only']='Emotes precisam de um personagem R15',['av.emote_failed']='N\u{e3}o deu para carregar o emote %s',[
'av.not_emote']='\u{201c}%s\u{201d} n\u{e3}o \u{e9} um emote',['av.asset_missing']=
'N\u{e3}o h\u{e1} item %s no cat\u{e1}logo',['av.emote_added']='Emote adicionado: %s',['av.emote_exists']=
'J\u{e1} est\u{e1} na roda: %s',['av.emote_removed']='Emote tirado: %s',['av.emotes_none']=
'Nenhum emote ainda. Adicione com addemote <id>.',['av.emotes_list']='Emotes: %s'},de={['c.wear']='Avatar tragen',[
'd.wear']=
'Tr\u{e4}gt den Avatar eines anderen Spielers: jemand auf diesem Server so wie hier, oder jeder Name / jede User-ID aus dem Profil. Nur du siehst es.'
,['c.outfit']='Outfit tragen',['d.outfit']='Tr\u{e4}gt eines deiner gespeicherten Outfits. Nur du siehst es.',[
'c.bundle']='Bundle tragen',['d.bundle']='Tr\u{e4}gt ein K\u{f6}rper-Bundle aus dem Katalog per ID. Nur du siehst es.',[
'c.saveoutfit']='Outfit speichern',['d.saveoutfit']='Speichert, was du gerade tr\u{e4}gst, als Outfit.',[
'c.renameoutfit']='Outfit umbenennen',['d.renameoutfit']='Gibt einem gespeicherten Outfit einen neuen Namen.',[
'c.deloutfit']='Outfit l\u{f6}schen',['d.deloutfit']='L\u{f6}scht ein gespeichertes Outfit.',['c.outfits']='Outfits',[
'd.outfits']='Zeigt deine gespeicherten Outfits.',['c.exportoutfit']='Outfit exportieren',['d.exportoutfit']=
[[Erstellt ein Autoexec-Skript, das das Outfit bei jedem Beitritt anzieht.]],['c.avatarrules']=
'Avatar-Regeln des Spiels',['d.avatarrules']=
'Passt getragene Looks an die Avatar-Regeln dieses Spiels an: Skalen, feste Teile, Accessoire-Gr\u{f6}\u{df}en.',[
'c.emote']='Emote spielen',['d.emote']=[[Spielt ein Emote von deinem Rad oder per ID. Nur R15; alle sehen es.]],[
'c.addemote']='Emote hinzuf\u{fc}gen',['d.addemote']='F\u{fc}gt deinem Rad ein Emote per Katalog-ID hinzu.',[
'c.delemote']='Emote entfernen',['d.delemote']='Nimmt ein Emote von deinem Rad.',['c.emotes']='Emotes',['d.emotes']=
'Zeigt die Emotes auf deinem Rad.',['av.no_character']='Dein Charakter ist noch nicht geladen',['av.no_character_of']=
'%s hat gerade keinen Charakter',['av.not_found']='Kein Roblox-Nutzer \u{201e}%s\u{201c}',['av.avatar_failed']=
'Der Avatar von %s lie\u{df} sich nicht laden',['av.bundle_bad']='Kein K\u{f6}rper-Bundle \u{201e}%s\u{201c}',[
'av.outfit_saved']='Outfit gespeichert: %s',['av.outfit_renamed']='Outfit %s hei\u{df}t jetzt %s',['av.outfit_deleted']=
'Outfit gel\u{f6}scht: %s',['av.outfits_none']='Noch keine Outfits. Speichere eins mit saveoutfit <name>.',[
'av.outfits_list']='Outfits: %s',['av.exported']='Kopiert und gespeichert unter %s',['av.exported_file']=
'Gespeichert unter %s',['av.export_failed']='Das Skript lie\u{df} sich weder speichern noch kopieren',['av.export_bad']=
'Dieses Outfit-Skript ist besch\u{e4}digt',['av.r15_only']='Emotes brauchen einen R15-Charakter',['av.emote_failed']=
'Emote %s lie\u{df} sich nicht laden',['av.not_emote']='\u{201e}%s\u{201c} ist kein Emote',['av.asset_missing']=
'Kein Katalog-Artikel %s',['av.emote_added']='Emote hinzugef\u{fc}gt: %s',['av.emote_exists']='Schon auf dem Rad: %s',[
'av.emote_removed']='Emote entfernt: %s',['av.emotes_none']='Noch keine Emotes. F\u{fc}ge eins mit addemote <id> hinzu.'
,['av.emotes_list']='Emotes: %s'}}return bundle end function __DARKLUA_BUNDLE_MODULES.U()local v=
__DARKLUA_BUNDLE_MODULES.cache.U if not v then v={c=__modImpl()}__DARKLUA_BUNDLE_MODULES.cache.U=v end return v.c end
end do local function __modImpl()local Types=__DARKLUA_BUNDLE_MODULES.c()local bundle={en={['c.avatar']='Avatar panel',[
'd.avatar']=[[Open the avatar panel: players here, outfits, body bundles, emotes.]],['c.emotewheel']='Emote wheel',[
'd.emotewheel']="Open TZAR's emote wheel.",['avu.title']='Avatar',['avu.only_you']='only you see it',['avu.search']=
'Name, @user or ID',['avu.reset']='Back to mine',['avu.tab_look']='Look',['avu.tab_catalog']='Catalog',['avu.tab_emotes'
]='Emotes',['avu.export']='Export',['avu.save']='Save outfit',['avu.save_short']='Save',['avu.status_mine']=
'Your own avatar',['avu.status_worn']='Wearing %s',['avu.src_server']='from this server',['avu.src_profile']=
'from their profile',['avu.src_outfit']='saved outfit',['avu.src_bundle']='catalog bundle',['avu.hint_unwear']=
'unwear \u{2014} back to yours',['avu.hint_wear']='wear <name> \u{2014} wear someone',['avu.server']=
'In this server \u{b7} %d',['avu.server_hint']='tap to wear as they look here',['avu.alone']=
'Nobody else here \u{2014} type a name above',['avu.more']='%d more players',['avu.outfits']='Outfits \u{b7} %d',[
'avu.save_current']='Save current',['avu.mine']='Mine',['avu.meta_mine']='yours',['avu.meta_worn']='worn',[
'avu.meta_saved']='saved',['avu.rules']='Game avatar rules',['avu.rules_sub']=
"this place's scales, forced parts and accessory sizes",['avu.catalog_search']='Search bodies',['avu.sort_best']=
'Bestselling',['avu.sort_fav']='Most favorited',['avu.sort_new']='Newest',['avu.kind_bodies']='Bodies',['avu.kind_mine']
='My outfits',['avu.body']='body',['avu.searching']='Searching\u{2026}',['avu.load_more']='Show more',['avu.wheel']=
'Wheel \u{b7} %d',['avu.emote_id']='Emote ID',['avu.tag_outfit']='outfit',['avu.wheel_empty']=
'No emotes on the wheel yet',['avu.outfit_first']='Outfit emotes first',['avu.outfit_first_sub']=
"the worn avatar's emotes take the first slots",['avu.own_wheel']="TZAR wheel instead of Roblox's",['avu.own_wheel_sub']
='opens with',['avu.wheel_play']='play',['avu.wheel_page']='page',['avu.wheel_scroll']='scroll',['avu.wheel_close']=
'close',['avu.wheel_touch']='tap to play \u{b7} tap outside to close',['avu.wheel_button']='emotes',['avu.slot']=
'slot %d',['avu.from_outfit']='from outfit',['avu.page']='page %d/%d'},ru={['c.avatar']=
'\u{41f}\u{430}\u{43d}\u{435}\u{43b}\u{44c} \u{430}\u{432}\u{430}\u{442}\u{430}\u{440}\u{430}',['d.avatar']=
'\u{41e}\u{442}\u{43a}\u{440}\u{44b}\u{442}\u{44c} \u{43f}\u{430}\u{43d}\u{435}\u{43b}\u{44c} \u{430}\u{432}\u{430}\u{442}\u{430}\u{440}\u{430}: \u{438}\u{433}\u{440}\u{43e}\u{43a}\u{438} \u{437}\u{434}\u{435}\u{441}\u{44c}, \u{43e}\u{431}\u{440}\u{430}\u{437}\u{44b}, \u{442}\u{435}\u{43b}\u{430} \u{438}\u{437} \u{43a}\u{430}\u{442}\u{430}\u{43b}\u{43e}\u{433}\u{430}, \u{44d}\u{43c}\u{43e}\u{446}\u{438}\u{438}.'
,['c.emotewheel']='\u{41a}\u{43e}\u{43b}\u{435}\u{441}\u{43e} \u{44d}\u{43c}\u{43e}\u{446}\u{438}\u{439}',[
'd.emotewheel']=
'\u{41e}\u{442}\u{43a}\u{440}\u{44b}\u{442}\u{44c} \u{43a}\u{43e}\u{43b}\u{435}\u{441}\u{43e} \u{44d}\u{43c}\u{43e}\u{446}\u{438}\u{439} TZAR.'
,['avu.title']='\u{410}\u{432}\u{430}\u{442}\u{430}\u{440}',['avu.only_you']=
'\u{432}\u{438}\u{434}\u{438}\u{448}\u{44c} \u{442}\u{43e}\u{43b}\u{44c}\u{43a}\u{43e} \u{442}\u{44b}',['avu.search']=
'\u{41d}\u{438}\u{43a}, @\u{438}\u{43c}\u{44f} \u{438}\u{43b}\u{438} ID',['avu.reset']=
'\u{412}\u{435}\u{440}\u{43d}\u{443}\u{442}\u{44c} \u{43c}\u{43e}\u{439}',['avu.tab_look']=
'\u{412}\u{43d}\u{435}\u{448}\u{43d}\u{43e}\u{441}\u{442}\u{44c}',['avu.tab_catalog']=
'\u{41a}\u{430}\u{442}\u{430}\u{43b}\u{43e}\u{433}',['avu.tab_emotes']='\u{42d}\u{43c}\u{43e}\u{446}\u{438}\u{438}',[
'avu.export']='\u{42d}\u{43a}\u{441}\u{43f}\u{43e}\u{440}\u{442}',['avu.save']=
'\u{421}\u{43e}\u{445}\u{440}\u{430}\u{43d}\u{438}\u{442}\u{44c} \u{43e}\u{431}\u{440}\u{430}\u{437}',['avu.save_short']
='\u{421}\u{43e}\u{445}\u{440}\u{430}\u{43d}\u{438}\u{442}\u{44c}',['avu.status_mine']=
'\u{421}\u{432}\u{43e}\u{439} \u{430}\u{432}\u{430}\u{442}\u{430}\u{440}',['avu.status_worn']=
'\u{41d}\u{430}\u{434}\u{435}\u{442} %s',['avu.src_server']='\u{441} \u{441}\u{435}\u{440}\u{432}\u{435}\u{440}\u{430}',
['avu.src_profile']='\u{438}\u{437} \u{43f}\u{440}\u{43e}\u{444}\u{438}\u{43b}\u{44f}',['avu.src_outfit']=
'\u{441}\u{43e}\u{445}\u{440}\u{430}\u{43d}\u{451}\u{43d}\u{43d}\u{44b}\u{439} \u{43e}\u{431}\u{440}\u{430}\u{437}',[
'avu.src_bundle']=
'\u{431}\u{430}\u{43d}\u{434}\u{43b} \u{438}\u{437} \u{43a}\u{430}\u{442}\u{430}\u{43b}\u{43e}\u{433}\u{430}',[
'avu.hint_unwear']='unwear \u{2014} \u{432}\u{435}\u{440}\u{43d}\u{443}\u{442}\u{44c} \u{441}\u{432}\u{43e}\u{439}',[
'avu.hint_wear']=
'wear <\u{43d}\u{438}\u{43a}> \u{2014} \u{43d}\u{430}\u{434}\u{435}\u{442}\u{44c} \u{447}\u{443}\u{436}\u{43e}\u{439}',[
'avu.server']='\u{41d}\u{430} \u{441}\u{435}\u{440}\u{432}\u{435}\u{440}\u{435} \u{b7} %d',['avu.server_hint']=
'\u{442}\u{430}\u{43f} \u{2014} \u{43d}\u{430}\u{434}\u{435}\u{442}\u{44c}, \u{43a}\u{430}\u{43a} \u{437}\u{434}\u{435}\u{441}\u{44c}'
,['avu.alone']=
'\u{41a}\u{440}\u{43e}\u{43c}\u{435} \u{442}\u{435}\u{431}\u{44f} \u{437}\u{434}\u{435}\u{441}\u{44c} \u{43d}\u{438}\u{43a}\u{43e}\u{433}\u{43e} \u{2014} \u{432}\u{432}\u{435}\u{434}\u{438} \u{43d}\u{438}\u{43a} \u{441}\u{432}\u{435}\u{440}\u{445}\u{443}'
,['avu.more']='\u{435}\u{449}\u{451} %d \u{438}\u{433}\u{440}\u{43e}\u{43a}\u{43e}\u{432}',['avu.outfits']=
'\u{41e}\u{431}\u{440}\u{430}\u{437}\u{44b} \u{b7} %d',['avu.save_current']=
'\u{421}\u{43e}\u{445}\u{440}\u{430}\u{43d}\u{438}\u{442}\u{44c} \u{442}\u{435}\u{43a}\u{443}\u{449}\u{435}\u{435}',[
'avu.mine']='\u{41c}\u{43e}\u{439}',['avu.meta_mine']='\u{441}\u{432}\u{43e}\u{439}',['avu.meta_worn']=
'\u{43d}\u{430}\u{434}\u{435}\u{442}',['avu.meta_saved']='\u{441}\u{43e}\u{445}\u{440}\u{430}\u{43d}\u{451}\u{43d}',[
'avu.rules']=
'\u{41f}\u{440}\u{430}\u{432}\u{438}\u{43b}\u{430} \u{430}\u{432}\u{430}\u{442}\u{430}\u{440}\u{430} \u{438}\u{433}\u{440}\u{44b}'
,['avu.rules_sub']=
'\u{43c}\u{430}\u{441}\u{448}\u{442}\u{430}\u{431}\u{44b}, \u{43e}\u{431}\u{44f}\u{437}\u{430}\u{442}\u{435}\u{43b}\u{44c}\u{43d}\u{44b}\u{435} \u{447}\u{430}\u{441}\u{442}\u{438} \u{438} \u{440}\u{430}\u{437}\u{43c}\u{435}\u{440} \u{430}\u{43a}\u{441}\u{435}\u{441}\u{441}\u{443}\u{430}\u{440}\u{43e}\u{432} \u{44d}\u{442}\u{43e}\u{433}\u{43e} \u{43f}\u{43b}\u{435}\u{439}\u{441}\u{430}'
,['avu.catalog_search']='\u{41f}\u{43e}\u{438}\u{441}\u{43a} \u{442}\u{435}\u{43b}',['avu.sort_best']=
'\u{411}\u{435}\u{441}\u{442}\u{441}\u{435}\u{43b}\u{43b}\u{435}\u{440}\u{44b}',['avu.sort_fav']=
'\u{412} \u{438}\u{437}\u{431}\u{440}\u{430}\u{43d}\u{43d}\u{43e}\u{43c}',['avu.sort_new']=
'\u{41d}\u{43e}\u{432}\u{44b}\u{435}',['avu.kind_bodies']='\u{422}\u{435}\u{43b}\u{430}',['avu.kind_mine']=
'\u{41c}\u{43e}\u{438} \u{43e}\u{431}\u{440}\u{430}\u{437}\u{44b}',['avu.body']='\u{442}\u{435}\u{43b}\u{43e}',[
'avu.searching']='\u{418}\u{449}\u{443}\u{2026}',['avu.load_more']=
'\u{41f}\u{43e}\u{43a}\u{430}\u{437}\u{430}\u{442}\u{44c} \u{435}\u{449}\u{451}',['avu.wheel']=
'\u{41a}\u{43e}\u{43b}\u{435}\u{441}\u{43e} \u{b7} %d',['avu.emote_id']='ID \u{44d}\u{43c}\u{43e}\u{446}\u{438}\u{438}',
['avu.tag_outfit']='\u{43e}\u{431}\u{440}\u{430}\u{437}',['avu.wheel_empty']=
'\u{41d}\u{430} \u{43a}\u{43e}\u{43b}\u{435}\u{441}\u{435} \u{43f}\u{43e}\u{43a}\u{430} \u{43d}\u{435}\u{442} \u{44d}\u{43c}\u{43e}\u{446}\u{438}\u{439}'
,['avu.outfit_first']=
'\u{421}\u{43d}\u{430}\u{447}\u{430}\u{43b}\u{430} \u{44d}\u{43c}\u{43e}\u{446}\u{438}\u{438} \u{43e}\u{431}\u{440}\u{430}\u{437}\u{430}'
,['avu.outfit_first_sub']=
'\u{44d}\u{43c}\u{43e}\u{446}\u{438}\u{438} \u{43d}\u{430}\u{434}\u{435}\u{442}\u{43e}\u{433}\u{43e} \u{430}\u{432}\u{430}\u{442}\u{430}\u{440}\u{430} \u{437}\u{430}\u{43d}\u{438}\u{43c}\u{430}\u{44e}\u{442} \u{43f}\u{435}\u{440}\u{432}\u{44b}\u{435} \u{441}\u{43b}\u{43e}\u{442}\u{44b}'
,['avu.own_wheel']='\u{41a}\u{43e}\u{43b}\u{435}\u{441}\u{43e} TZAR \u{432}\u{43c}\u{435}\u{441}\u{442}\u{43e} Roblox',[
'avu.own_wheel_sub']=
'\u{43e}\u{442}\u{43a}\u{440}\u{44b}\u{432}\u{430}\u{435}\u{442}\u{441}\u{44f} \u{43a}\u{43b}\u{430}\u{432}\u{438}\u{448}\u{435}\u{439}'
,['avu.wheel_play']='\u{441}\u{44b}\u{433}\u{440}\u{430}\u{442}\u{44c}',['avu.wheel_page']=
'\u{441}\u{442}\u{440}\u{430}\u{43d}\u{438}\u{446}\u{430}',['avu.wheel_scroll']=
'\u{43b}\u{438}\u{441}\u{442}\u{430}\u{442}\u{44c}',['avu.wheel_close']=
'\u{437}\u{430}\u{43a}\u{440}\u{44b}\u{442}\u{44c}',['avu.wheel_touch']=
'\u{442}\u{430}\u{43f} \u{2014} \u{441}\u{44b}\u{433}\u{440}\u{430}\u{442}\u{44c} \u{b7} \u{442}\u{430}\u{43f} \u{43c}\u{438}\u{43c}\u{43e} \u{2014} \u{437}\u{430}\u{43a}\u{440}\u{44b}\u{442}\u{44c}'
,['avu.wheel_button']='\u{44d}\u{43c}\u{43e}\u{446}\u{438}\u{438}',['avu.slot']='\u{441}\u{43b}\u{43e}\u{442} %d',[
'avu.from_outfit']='\u{438}\u{437} \u{43e}\u{431}\u{440}\u{430}\u{437}\u{430}',['avu.page']=
'\u{441}\u{442}\u{440}\u{430}\u{43d}\u{438}\u{446}\u{430} %d/%d'},uk={['c.avatar']=
'\u{41f}\u{430}\u{43d}\u{435}\u{43b}\u{44c} \u{430}\u{432}\u{430}\u{442}\u{430}\u{440}\u{430}',['d.avatar']=
'\u{412}\u{456}\u{434}\u{43a}\u{440}\u{438}\u{442}\u{438} \u{43f}\u{430}\u{43d}\u{435}\u{43b}\u{44c} \u{430}\u{432}\u{430}\u{442}\u{430}\u{440}\u{430}: \u{433}\u{440}\u{430}\u{432}\u{446}\u{456} \u{442}\u{443}\u{442}, \u{43e}\u{431}\u{440}\u{430}\u{437}\u{438}, \u{442}\u{456}\u{43b}\u{430} \u{437} \u{43a}\u{430}\u{442}\u{430}\u{43b}\u{43e}\u{433}\u{443}, \u{435}\u{43c}\u{43e}\u{446}\u{456}\u{457}.'
,['c.emotewheel']='\u{41a}\u{43e}\u{43b}\u{435}\u{441}\u{43e} \u{435}\u{43c}\u{43e}\u{446}\u{456}\u{439}',[
'd.emotewheel']=
'\u{412}\u{456}\u{434}\u{43a}\u{440}\u{438}\u{442}\u{438} \u{43a}\u{43e}\u{43b}\u{435}\u{441}\u{43e} \u{435}\u{43c}\u{43e}\u{446}\u{456}\u{439} TZAR.'
,['avu.title']='\u{410}\u{432}\u{430}\u{442}\u{430}\u{440}',['avu.only_you']=
'\u{431}\u{430}\u{447}\u{438}\u{448} \u{43b}\u{438}\u{448}\u{435} \u{442}\u{438}',['avu.search']=
"\u{41d}\u{456}\u{43a}, @\u{456}\u{43c}'\u{44f} \u{430}\u{431}\u{43e} ID",['avu.reset']=
'\u{41f}\u{43e}\u{432}\u{435}\u{440}\u{43d}\u{443}\u{442}\u{438} \u{43c}\u{456}\u{439}',['avu.tab_look']=
'\u{417}\u{43e}\u{432}\u{43d}\u{456}\u{448}\u{43d}\u{456}\u{441}\u{442}\u{44c}',['avu.tab_catalog']=
'\u{41a}\u{430}\u{442}\u{430}\u{43b}\u{43e}\u{433}',['avu.tab_emotes']='\u{415}\u{43c}\u{43e}\u{446}\u{456}\u{457}',[
'avu.export']='\u{415}\u{43a}\u{441}\u{43f}\u{43e}\u{440}\u{442}',['avu.save']=
'\u{417}\u{431}\u{435}\u{440}\u{435}\u{433}\u{442}\u{438} \u{43e}\u{431}\u{440}\u{430}\u{437}',['avu.save_short']=
'\u{417}\u{431}\u{435}\u{440}\u{435}\u{433}\u{442}\u{438}',['avu.status_mine']=
'\u{421}\u{432}\u{456}\u{439} \u{430}\u{432}\u{430}\u{442}\u{430}\u{440}',['avu.status_worn']=
'\u{412}\u{434}\u{44f}\u{433}\u{43d}\u{443}\u{442}\u{43e} %s',['avu.src_server']=
'\u{437} \u{441}\u{435}\u{440}\u{432}\u{435}\u{440}\u{430}',['avu.src_profile']=
'\u{437} \u{43f}\u{440}\u{43e}\u{444}\u{456}\u{43b}\u{44e}',['avu.src_outfit']=
'\u{437}\u{431}\u{435}\u{440}\u{435}\u{436}\u{435}\u{43d}\u{438}\u{439} \u{43e}\u{431}\u{440}\u{430}\u{437}',[
'avu.src_bundle']='\u{431}\u{430}\u{43d}\u{434}\u{43b} \u{437} \u{43a}\u{430}\u{442}\u{430}\u{43b}\u{43e}\u{433}\u{443}'
,['avu.hint_unwear']=
'unwear \u{2014} \u{43f}\u{43e}\u{432}\u{435}\u{440}\u{43d}\u{443}\u{442}\u{438} \u{441}\u{432}\u{456}\u{439}',[
'avu.hint_wear']=
'wear <\u{43d}\u{456}\u{43a}> \u{2014} \u{432}\u{434}\u{44f}\u{433}\u{43d}\u{443}\u{442}\u{438} \u{447}\u{443}\u{436}\u{438}\u{439}'
,['avu.server']='\u{41d}\u{430} \u{441}\u{435}\u{440}\u{432}\u{435}\u{440}\u{456} \u{b7} %d',['avu.server_hint']=
'\u{442}\u{430}\u{43f} \u{2014} \u{432}\u{434}\u{44f}\u{433}\u{43d}\u{443}\u{442}\u{438}, \u{44f}\u{43a} \u{442}\u{443}\u{442}'
,['avu.alone']=
'\u{41e}\u{43a}\u{440}\u{456}\u{43c} \u{442}\u{435}\u{431}\u{435} \u{442}\u{443}\u{442} \u{43d}\u{456}\u{43a}\u{43e}\u{433}\u{43e} \u{2014} \u{432}\u{432}\u{435}\u{434}\u{438} \u{43d}\u{456}\u{43a} \u{437}\u{432}\u{435}\u{440}\u{445}\u{443}'
,['avu.more']='\u{449}\u{435} %d \u{433}\u{440}\u{430}\u{432}\u{446}\u{456}\u{432}',['avu.outfits']=
'\u{41e}\u{431}\u{440}\u{430}\u{437}\u{438} \u{b7} %d',['avu.save_current']=
'\u{417}\u{431}\u{435}\u{440}\u{435}\u{433}\u{442}\u{438} \u{43f}\u{43e}\u{442}\u{43e}\u{447}\u{43d}\u{435}',['avu.mine'
]='\u{41c}\u{456}\u{439}',['avu.meta_mine']='\u{441}\u{432}\u{456}\u{439}',['avu.meta_worn']=
'\u{432}\u{434}\u{44f}\u{433}\u{43d}\u{443}\u{442}\u{43e}',['avu.meta_saved']=
'\u{437}\u{431}\u{435}\u{440}\u{435}\u{436}\u{435}\u{43d}\u{43e}',['avu.rules']=
'\u{41f}\u{440}\u{430}\u{432}\u{438}\u{43b}\u{430} \u{430}\u{432}\u{430}\u{442}\u{430}\u{440}\u{430} \u{433}\u{440}\u{438}'
,['avu.rules_sub']=
"\u{43c}\u{430}\u{441}\u{448}\u{442}\u{430}\u{431}\u{438}, \u{43e}\u{431}\u{43e}\u{432}'\u{44f}\u{437}\u{43a}\u{43e}\u{432}\u{456} \u{447}\u{430}\u{441}\u{442}\u{438}\u{43d}\u{438} \u{439} \u{440}\u{43e}\u{437}\u{43c}\u{456}\u{440} \u{430}\u{43a}\u{441}\u{435}\u{441}\u{443}\u{430}\u{440}\u{456}\u{432} \u{446}\u{44c}\u{43e}\u{433}\u{43e} \u{43f}\u{43b}\u{435}\u{439}\u{441}\u{443}"
,['avu.catalog_search']='\u{41f}\u{43e}\u{448}\u{443}\u{43a} \u{442}\u{456}\u{43b}',['avu.sort_best']=
'\u{411}\u{435}\u{441}\u{442}\u{441}\u{435}\u{43b}\u{435}\u{440}\u{438}',['avu.sort_fav']=
'\u{412} \u{43e}\u{431}\u{440}\u{430}\u{43d}\u{43e}\u{43c}\u{443}',['avu.sort_new']='\u{41d}\u{43e}\u{432}\u{456}',[
'avu.kind_bodies']='\u{422}\u{456}\u{43b}\u{430}',['avu.kind_mine']=
'\u{41c}\u{43e}\u{457} \u{43e}\u{431}\u{440}\u{430}\u{437}\u{438}',['avu.body']='\u{442}\u{456}\u{43b}\u{43e}',[
'avu.searching']='\u{428}\u{443}\u{43a}\u{430}\u{44e}\u{2026}',['avu.load_more']=
'\u{41f}\u{43e}\u{43a}\u{430}\u{437}\u{430}\u{442}\u{438} \u{449}\u{435}',['avu.wheel']=
'\u{41a}\u{43e}\u{43b}\u{435}\u{441}\u{43e} \u{b7} %d',['avu.emote_id']='ID \u{435}\u{43c}\u{43e}\u{446}\u{456}\u{457}',
['avu.tag_outfit']='\u{43e}\u{431}\u{440}\u{430}\u{437}',['avu.wheel_empty']=
'\u{41d}\u{430} \u{43a}\u{43e}\u{43b}\u{435}\u{441}\u{456} \u{43f}\u{43e}\u{43a}\u{438} \u{43d}\u{435}\u{43c}\u{430}\u{454} \u{435}\u{43c}\u{43e}\u{446}\u{456}\u{439}'
,['avu.outfit_first']=
'\u{421}\u{43f}\u{435}\u{440}\u{448}\u{443} \u{435}\u{43c}\u{43e}\u{446}\u{456}\u{457} \u{43e}\u{431}\u{440}\u{430}\u{437}\u{443}'
,['avu.outfit_first_sub']=
'\u{435}\u{43c}\u{43e}\u{446}\u{456}\u{457} \u{432}\u{434}\u{44f}\u{433}\u{43d}\u{443}\u{442}\u{43e}\u{433}\u{43e} \u{430}\u{432}\u{430}\u{442}\u{430}\u{440}\u{430} \u{437}\u{430}\u{439}\u{43c}\u{430}\u{44e}\u{442}\u{44c} \u{43f}\u{435}\u{440}\u{448}\u{456} \u{441}\u{43b}\u{43e}\u{442}\u{438}'
,['avu.own_wheel']=
'\u{41a}\u{43e}\u{43b}\u{435}\u{441}\u{43e} TZAR \u{437}\u{430}\u{43c}\u{456}\u{441}\u{442}\u{44c} Roblox',[
'avu.own_wheel_sub']=
'\u{432}\u{456}\u{434}\u{43a}\u{440}\u{438}\u{432}\u{430}\u{454}\u{442}\u{44c}\u{441}\u{44f} \u{43a}\u{43b}\u{430}\u{432}\u{456}\u{448}\u{435}\u{44e}'
,['avu.wheel_play']='\u{437}\u{456}\u{433}\u{440}\u{430}\u{442}\u{438}',['avu.wheel_page']=
'\u{441}\u{442}\u{43e}\u{440}\u{456}\u{43d}\u{43a}\u{430}',['avu.wheel_scroll']=
'\u{433}\u{43e}\u{440}\u{442}\u{430}\u{442}\u{438}',['avu.wheel_close']=
'\u{437}\u{430}\u{43a}\u{440}\u{438}\u{442}\u{438}',['avu.wheel_touch']=
'\u{442}\u{430}\u{43f} \u{2014} \u{437}\u{456}\u{433}\u{440}\u{430}\u{442}\u{438} \u{b7} \u{442}\u{430}\u{43f} \u{43f}\u{43e}\u{432}\u{437} \u{2014} \u{437}\u{430}\u{43a}\u{440}\u{438}\u{442}\u{438}'
,['avu.wheel_button']='\u{435}\u{43c}\u{43e}\u{446}\u{456}\u{457}',['avu.slot']='\u{441}\u{43b}\u{43e}\u{442} %d',[
'avu.from_outfit']='\u{437} \u{43e}\u{431}\u{440}\u{430}\u{437}\u{443}',['avu.page']=
'\u{441}\u{442}\u{43e}\u{440}\u{456}\u{43d}\u{43a}\u{430} %d/%d'},es={['c.avatar']='Panel de avatar',['d.avatar']=
'Abre el panel de avatar: jugadores aqu\u{ed}, atuendos, cuerpos del cat\u{e1}logo, emotes.',['c.emotewheel']=
'Rueda de emotes',['d.emotewheel']='Abre la rueda de emotes de TZAR.',['avu.title']='Avatar',['avu.only_you']=
'solo lo ves t\u{fa}',['avu.search']='Nombre, @usuario o ID',['avu.reset']='Volver al m\u{ed}o',['avu.tab_look']=
'Aspecto',['avu.tab_catalog']='Cat\u{e1}logo',['avu.tab_emotes']='Emotes',['avu.export']='Exportar',['avu.save']=
'Guardar atuendo',['avu.save_short']='Guardar',['avu.status_mine']='Tu propio avatar',['avu.status_worn']='Llevas %s',[
'avu.src_server']='de este servidor',['avu.src_profile']='de su perfil',['avu.src_outfit']='atuendo guardado',[
'avu.src_bundle']='paquete del cat\u{e1}logo',['avu.hint_unwear']='unwear \u{2014} volver al tuyo',['avu.hint_wear']=
'wear <nombre> \u{2014} usar otro',['avu.server']='En este servidor \u{b7} %d',['avu.server_hint']=
'toca para usarlo como se ve aqu\u{ed}',['avu.alone']='No hay nadie m\u{e1}s \u{2014} escribe un nombre arriba',[
'avu.more']='%d jugadores m\u{e1}s',['avu.outfits']='Atuendos \u{b7} %d',['avu.save_current']='Guardar el actual',[
'avu.mine']='El m\u{ed}o',['avu.meta_mine']='tuyo',['avu.meta_worn']='puesto',['avu.meta_saved']='guardado',['avu.rules'
]='Reglas de avatar del juego',['avu.rules_sub']='escalas, partes forzadas y tama\u{f1}o de accesorios de este juego',[
'avu.catalog_search']='Buscar cuerpos',['avu.sort_best']='M\u{e1}s vendidos',['avu.sort_fav']='M\u{e1}s favoritos',[
'avu.sort_new']='Nuevos',['avu.kind_bodies']='Cuerpos',['avu.kind_mine']='Mis atuendos',['avu.body']='cuerpo',[
'avu.searching']='Buscando\u{2026}',['avu.load_more']='Ver m\u{e1}s',['avu.wheel']='Rueda \u{b7} %d',['avu.emote_id']=
'ID del emote',['avu.tag_outfit']='atuendo',['avu.wheel_empty']='A\u{fa}n no hay emotes en la rueda',['avu.outfit_first'
]='Primero los emotes del atuendo',['avu.outfit_first_sub']='los emotes del avatar puesto ocupan los primeros huecos',[
'avu.own_wheel']='Rueda de TZAR en lugar de la de Roblox',['avu.own_wheel_sub']='se abre con',['avu.wheel_play']='hacer'
,['avu.wheel_page']='p\u{e1}gina',['avu.wheel_scroll']='pasar',['avu.wheel_close']='cerrar',['avu.wheel_touch']=
'toca para hacerlo \u{b7} toca fuera para cerrar',['avu.wheel_button']='emotes',['avu.slot']='hueco %d',[
'avu.from_outfit']='del atuendo',['avu.page']='p\u{e1}gina %d/%d'},pt={['c.avatar']='Painel de avatar',['d.avatar']=
'Abre o painel de avatar: jogadores aqui, visuais, corpos do cat\u{e1}logo, emotes.',['c.emotewheel']='Roda de emotes',[
'd.emotewheel']='Abre a roda de emotes do TZAR.',['avu.title']='Avatar',['avu.only_you']='s\u{f3} voc\u{ea} v\u{ea}',[
'avu.search']='Nome, @usu\u{e1}rio ou ID',['avu.reset']='Voltar ao meu',['avu.tab_look']='Visual',['avu.tab_catalog']=
'Cat\u{e1}logo',['avu.tab_emotes']='Emotes',['avu.export']='Exportar',['avu.save']='Salvar visual',['avu.save_short']=
'Salvar',['avu.status_mine']='Seu pr\u{f3}prio avatar',['avu.status_worn']='Vestindo %s',['avu.src_server']=
'deste servidor',['avu.src_profile']='do perfil',['avu.src_outfit']='visual salvo',['avu.src_bundle']=
'pacote do cat\u{e1}logo',['avu.hint_unwear']='unwear \u{2014} voltar ao seu',['avu.hint_wear']=
'wear <nome> \u{2014} vestir outro',['avu.server']='Neste servidor \u{b7} %d',['avu.server_hint']=
'toque para vestir como est\u{e1} aqui',['avu.alone']='N\u{e3}o h\u{e1} mais ningu\u{e9}m \u{2014} digite um nome acima'
,['avu.more']='mais %d jogadores',['avu.outfits']='Visuais \u{b7} %d',['avu.save_current']='Salvar o atual',['avu.mine']
='O meu',['avu.meta_mine']='seu',['avu.meta_worn']='vestido',['avu.meta_saved']='salvo',['avu.rules']=
'Regras de avatar do jogo',['avu.rules_sub']='escalas, partes obrigat\u{f3}rias e tamanho de acess\u{f3}rios deste jogo'
,['avu.catalog_search']='Buscar corpos',['avu.sort_best']='Mais vendidos',['avu.sort_fav']='Mais favoritados',[
'avu.sort_new']='Novos',['avu.kind_bodies']='Corpos',['avu.kind_mine']='Meus visuais',['avu.body']='corpo',[
'avu.searching']='Buscando\u{2026}',['avu.load_more']='Mostrar mais',['avu.wheel']='Roda \u{b7} %d',['avu.emote_id']=
'ID do emote',['avu.tag_outfit']='visual',['avu.wheel_empty']='Ainda n\u{e3}o h\u{e1} emotes na roda',[
'avu.outfit_first']='Emotes do visual primeiro',['avu.outfit_first_sub']=
'os emotes do avatar vestido ocupam os primeiros espa\u{e7}os',['avu.own_wheel']='Roda do TZAR no lugar da do Roblox',[
'avu.own_wheel_sub']='abre com',['avu.wheel_play']='fazer',['avu.wheel_page']='p\u{e1}gina',['avu.wheel_scroll']='rolar'
,['avu.wheel_close']='fechar',['avu.wheel_touch']='toque para fazer \u{b7} toque fora para fechar',['avu.wheel_button']=
'emotes',['avu.slot']='espa\u{e7}o %d',['avu.from_outfit']='do visual',['avu.page']='p\u{e1}gina %d/%d'},de={['c.avatar'
]='Avatar-Panel',['d.avatar']=
'\u{d6}ffnet das Avatar-Panel: Spieler hier, Outfits, K\u{f6}rper aus dem Katalog, Emotes.',['c.emotewheel']='Emote-Rad'
,['d.emotewheel']='\u{d6}ffnet das Emote-Rad von TZAR.',['avu.title']='Avatar',['avu.only_you']='nur du siehst es',[
'avu.search']='Name, @Nutzer oder ID',['avu.reset']='Zur\u{fc}ck zu meinem',['avu.tab_look']='Aussehen',[
'avu.tab_catalog']='Katalog',['avu.tab_emotes']='Emotes',['avu.export']='Export',['avu.save']='Outfit speichern',[
'avu.save_short']='Speichern',['avu.status_mine']='Dein eigener Avatar',['avu.status_worn']='Du tr\u{e4}gst %s',[
'avu.src_server']='von diesem Server',['avu.src_profile']='aus dem Profil',['avu.src_outfit']='gespeichertes Outfit',[
'avu.src_bundle']='Katalog-Bundle',['avu.hint_unwear']='unwear \u{2014} zur\u{fc}ck zu deinem',['avu.hint_wear']=
'wear <name> \u{2014} jemanden tragen',['avu.server']='Auf diesem Server \u{b7} %d',['avu.server_hint']=
'tippen, um es wie hier zu tragen',['avu.alone']='Sonst ist niemand hier \u{2014} oben einen Namen eingeben',['avu.more'
]='%d weitere Spieler',['avu.outfits']='Outfits \u{b7} %d',['avu.save_current']='Aktuelles speichern',['avu.mine']=
'Meins',['avu.meta_mine']='deins',['avu.meta_worn']='getragen',['avu.meta_saved']='gespeichert',['avu.rules']=
'Avatar-Regeln des Spiels',['avu.rules_sub']='Skalen, feste Teile und Accessoire-Gr\u{f6}\u{df}en dieses Spiels',[
'avu.catalog_search']='K\u{f6}rper suchen',['avu.sort_best']='Bestseller',['avu.sort_fav']='Beliebteste',['avu.sort_new'
]='Neueste',['avu.kind_bodies']='K\u{f6}rper',['avu.kind_mine']='Meine Outfits',['avu.body']='K\u{f6}rper',[
'avu.searching']='Suche\u{2026}',['avu.load_more']='Mehr zeigen',['avu.wheel']='Rad \u{b7} %d',['avu.emote_id']=
'Emote-ID',['avu.tag_outfit']='Outfit',['avu.wheel_empty']='Noch keine Emotes auf dem Rad',['avu.outfit_first']=
'Outfit-Emotes zuerst',['avu.outfit_first_sub']='die Emotes des getragenen Avatars kommen zuerst',['avu.own_wheel']=
'TZAR-Rad statt Roblox-Rad',['avu.own_wheel_sub']='\u{f6}ffnet mit',['avu.wheel_play']='spielen',['avu.wheel_page']=
'Seite',['avu.wheel_scroll']='bl\u{e4}ttern',['avu.wheel_close']='schlie\u{df}en',['avu.wheel_touch']=
'tippen zum Spielen \u{b7} daneben tippen zum Schlie\u{df}en',['avu.wheel_button']='Emotes',['avu.slot']='Platz %d',[
'avu.from_outfit']='aus dem Outfit',['avu.page']='Seite %d/%d'}}return bundle end function __DARKLUA_BUNDLE_MODULES.V()
local v=__DARKLUA_BUNDLE_MODULES.cache.V if not v then v={c=__modImpl()}__DARKLUA_BUNDLE_MODULES.cache.V=v end return v.
c end end do local function __modImpl()local Types=__DARKLUA_BUNDLE_MODULES.c()local bundle={en={['c.fly']='Fly',[
'd.fly']=[[Fly around. WASD to move, Space and Ctrl for height; on a phone, the stick and the jump button.]],[
'c.flyspeed']='Fly speed',['d.flyspeed']='How fast fly moves.',['c.noclip']='Noclip',['d.noclip']=
'Walk through walls. Only your own character.',['c.speed']='Walk speed',['d.speed']=
"Walk speed. Without a value it goes back to the game's own.",['c.jumppower']='Jump power',['d.jumppower']=
"Jump power. Without a value it goes back to the game's own.",['c.infjump']='Infinite jump',['d.infjump']=
'Jump again in mid-air.',['c.sit']='Sit',['d.sit']='Sit down where you stand.',['c.lay']='Lay down',['d.lay']=
'Lie down where you stand.',['c.setwp']='Save waypoint',['d.setwp']=
[[Save where you stand as a waypoint. Waypoints are kept per place.]],['c.wp']='Go to waypoint',['d.wp']=
'Move your character to a saved waypoint.',['c.delwp']='Delete waypoint',['d.delwp']='Delete a saved waypoint.',[
'c.waypoints']='Waypoints',['d.waypoints']='List the waypoints saved for this place.',['c.antiafk']='Anti-AFK',[
'd.antiafk']='Stop the game from kicking you for being idle.',['c.respawn']='Respawn',['d.respawn']=
'Respawn your character.',['c.refresh']='Refresh',['d.refresh']='Respawn and come back to the same spot.',[
'chr.no_character']='Your character is not loaded yet',['chr.wp_saved']='Waypoint \u{201c}%s\u{201d} saved',[
'chr.wp_moved']='Moved to \u{201c}%s\u{201d}',['chr.wp_deleted']='Waypoint \u{201c}%s\u{201d} deleted',['chr.wp_list']=
'Waypoints: %s',['chr.wp_none']=[[No waypoints for this place yet. Save one with setwp <name>.]],['chr.respawned']=
'Respawned'},ru={['c.fly']='\u{41f}\u{43e}\u{43b}\u{451}\u{442}',['d.fly']=
'\u{41b}\u{435}\u{442}\u{430}\u{442}\u{44c}. WASD \u{2014} \u{434}\u{432}\u{438}\u{436}\u{435}\u{43d}\u{438}\u{435}, \u{43f}\u{440}\u{43e}\u{431}\u{435}\u{43b} \u{438} Ctrl \u{2014} \u{432}\u{44b}\u{441}\u{43e}\u{442}\u{430}; \u{43d}\u{430} \u{442}\u{435}\u{43b}\u{435}\u{444}\u{43e}\u{43d}\u{435} \u{2014} \u{441}\u{442}\u{438}\u{43a} \u{438} \u{43a}\u{43d}\u{43e}\u{43f}\u{43a}\u{430} \u{43f}\u{440}\u{44b}\u{436}\u{43a}\u{430}.'
,['c.flyspeed']='\u{421}\u{43a}\u{43e}\u{440}\u{43e}\u{441}\u{442}\u{44c} \u{43f}\u{43e}\u{43b}\u{451}\u{442}\u{430}',[
'd.flyspeed']=
'\u{421} \u{43a}\u{430}\u{43a}\u{43e}\u{439} \u{441}\u{43a}\u{43e}\u{440}\u{43e}\u{441}\u{442}\u{44c}\u{44e} \u{43b}\u{435}\u{442}\u{430}\u{435}\u{442} fly.'
,['c.noclip']='\u{421}\u{43a}\u{432}\u{43e}\u{437}\u{44c} \u{441}\u{442}\u{435}\u{43d}\u{44b}',['d.noclip']=
'\u{41f}\u{440}\u{43e}\u{445}\u{43e}\u{434}\u{438}\u{442}\u{44c} \u{441}\u{43a}\u{432}\u{43e}\u{437}\u{44c} \u{441}\u{442}\u{435}\u{43d}\u{44b}. \u{422}\u{43e}\u{43b}\u{44c}\u{43a}\u{43e} \u{441}\u{432}\u{43e}\u{439} \u{43f}\u{435}\u{440}\u{441}\u{43e}\u{43d}\u{430}\u{436}.'
,['c.speed']='\u{421}\u{43a}\u{43e}\u{440}\u{43e}\u{441}\u{442}\u{44c}',['d.speed']=
'\u{421}\u{43a}\u{43e}\u{440}\u{43e}\u{441}\u{442}\u{44c} \u{445}\u{43e}\u{434}\u{44c}\u{431}\u{44b}. \u{411}\u{435}\u{437} \u{437}\u{43d}\u{430}\u{447}\u{435}\u{43d}\u{438}\u{44f} \u{2014} \u{43a}\u{430}\u{43a} \u{437}\u{430}\u{434}\u{430}\u{43b}\u{430} \u{438}\u{433}\u{440}\u{430}.'
,['c.jumppower']='\u{421}\u{438}\u{43b}\u{430} \u{43f}\u{440}\u{44b}\u{436}\u{43a}\u{430}',['d.jumppower']=
'\u{421}\u{438}\u{43b}\u{430} \u{43f}\u{440}\u{44b}\u{436}\u{43a}\u{430}. \u{411}\u{435}\u{437} \u{437}\u{43d}\u{430}\u{447}\u{435}\u{43d}\u{438}\u{44f} \u{2014} \u{43a}\u{430}\u{43a} \u{437}\u{430}\u{434}\u{430}\u{43b}\u{430} \u{438}\u{433}\u{440}\u{430}.'
,['c.infjump']=
'\u{411}\u{435}\u{441}\u{43a}\u{43e}\u{43d}\u{435}\u{447}\u{43d}\u{44b}\u{439} \u{43f}\u{440}\u{44b}\u{436}\u{43e}\u{43a}'
,['d.infjump']=
'\u{41f}\u{440}\u{44b}\u{433}\u{430}\u{442}\u{44c} \u{435}\u{449}\u{451} \u{440}\u{430}\u{437} \u{43f}\u{440}\u{44f}\u{43c}\u{43e} \u{432} \u{432}\u{43e}\u{437}\u{434}\u{443}\u{445}\u{435}.'
,['c.sit']='\u{421}\u{435}\u{441}\u{442}\u{44c}',['d.sit']=
'\u{421}\u{435}\u{441}\u{442}\u{44c} \u{43d}\u{430} \u{43c}\u{435}\u{441}\u{442}\u{435}.',['c.lay']=
'\u{41b}\u{435}\u{447}\u{44c}',['d.lay']=
'\u{41b}\u{435}\u{447}\u{44c} \u{43d}\u{430} \u{43c}\u{435}\u{441}\u{442}\u{435}.',['c.setwp']=
'\u{421}\u{43e}\u{445}\u{440}\u{430}\u{43d}\u{438}\u{442}\u{44c} \u{442}\u{43e}\u{447}\u{43a}\u{443}',['d.setwp']=
'\u{421}\u{43e}\u{445}\u{440}\u{430}\u{43d}\u{438}\u{442}\u{44c} \u{442}\u{435}\u{43a}\u{443}\u{449}\u{435}\u{435} \u{43c}\u{435}\u{441}\u{442}\u{43e} \u{43a}\u{430}\u{43a} \u{442}\u{43e}\u{447}\u{43a}\u{443}. \u{422}\u{43e}\u{447}\u{43a}\u{438} \u{441}\u{432}\u{43e}\u{438} \u{434}\u{43b}\u{44f} \u{43a}\u{430}\u{436}\u{434}\u{43e}\u{433}\u{43e} \u{43f}\u{43b}\u{435}\u{439}\u{441}\u{430}.'
,['c.wp']='\u{41a} \u{442}\u{43e}\u{447}\u{43a}\u{435}',['d.wp']=
'\u{41f}\u{435}\u{440}\u{435}\u{43c}\u{435}\u{441}\u{442}\u{438}\u{442}\u{44c} \u{441}\u{432}\u{43e}\u{435}\u{433}\u{43e} \u{43f}\u{435}\u{440}\u{441}\u{43e}\u{43d}\u{430}\u{436}\u{430} \u{43a} \u{441}\u{43e}\u{445}\u{440}\u{430}\u{43d}\u{451}\u{43d}\u{43d}\u{43e}\u{439} \u{442}\u{43e}\u{447}\u{43a}\u{435}.'
,['c.delwp']='\u{423}\u{434}\u{430}\u{43b}\u{438}\u{442}\u{44c} \u{442}\u{43e}\u{447}\u{43a}\u{443}',['d.delwp']=
'\u{423}\u{434}\u{430}\u{43b}\u{438}\u{442}\u{44c} \u{441}\u{43e}\u{445}\u{440}\u{430}\u{43d}\u{451}\u{43d}\u{43d}\u{443}\u{44e} \u{442}\u{43e}\u{447}\u{43a}\u{443}.'
,['c.waypoints']='\u{422}\u{43e}\u{447}\u{43a}\u{438}',['d.waypoints']=
'\u{421}\u{43f}\u{438}\u{441}\u{43e}\u{43a} \u{442}\u{43e}\u{447}\u{435}\u{43a} \u{44d}\u{442}\u{43e}\u{433}\u{43e} \u{43f}\u{43b}\u{435}\u{439}\u{441}\u{430}.'
,['c.antiafk']='\u{410}\u{43d}\u{442}\u{438}-\u{410}\u{424}\u{41a}',['d.antiafk']=
'\u{418}\u{433}\u{440}\u{430} \u{43d}\u{435} \u{432}\u{44b}\u{43a}\u{438}\u{43d}\u{435}\u{442} \u{437}\u{430} \u{431}\u{435}\u{437}\u{434}\u{435}\u{439}\u{441}\u{442}\u{432}\u{438}\u{435}.'
,['c.respawn']='\u{412}\u{43e}\u{437}\u{440}\u{43e}\u{434}\u{438}\u{442}\u{44c}\u{441}\u{44f}',['d.respawn']=
'\u{412}\u{43e}\u{437}\u{440}\u{43e}\u{434}\u{438}\u{442}\u{44c} \u{441}\u{432}\u{43e}\u{435}\u{433}\u{43e} \u{43f}\u{435}\u{440}\u{441}\u{43e}\u{43d}\u{430}\u{436}\u{430}.'
,['c.refresh']='\u{41e}\u{431}\u{43d}\u{43e}\u{432}\u{438}\u{442}\u{44c}',['d.refresh']=
'\u{412}\u{43e}\u{437}\u{440}\u{43e}\u{434}\u{438}\u{442}\u{44c}\u{441}\u{44f} \u{438} \u{432}\u{435}\u{440}\u{43d}\u{443}\u{442}\u{44c}\u{441}\u{44f} \u{43d}\u{430} \u{442}\u{43e} \u{436}\u{435} \u{43c}\u{435}\u{441}\u{442}\u{43e}.'
,['chr.no_character']=
'\u{41f}\u{435}\u{440}\u{441}\u{43e}\u{43d}\u{430}\u{436} \u{435}\u{449}\u{451} \u{43d}\u{435} \u{437}\u{430}\u{433}\u{440}\u{443}\u{437}\u{438}\u{43b}\u{441}\u{44f}'
,['chr.wp_saved']=
'\u{422}\u{43e}\u{447}\u{43a}\u{430} \u{ab}%s\u{bb} \u{441}\u{43e}\u{445}\u{440}\u{430}\u{43d}\u{435}\u{43d}\u{430}',[
'chr.wp_moved']='\u{412}\u{44b} \u{443} \u{442}\u{43e}\u{447}\u{43a}\u{438} \u{ab}%s\u{bb}',['chr.wp_deleted']=
'\u{422}\u{43e}\u{447}\u{43a}\u{430} \u{ab}%s\u{bb} \u{443}\u{434}\u{430}\u{43b}\u{435}\u{43d}\u{430}',['chr.wp_list']=
'\u{422}\u{43e}\u{447}\u{43a}\u{438}: %s',['chr.wp_none']=
'\u{412} \u{44d}\u{442}\u{43e}\u{43c} \u{43f}\u{43b}\u{435}\u{439}\u{441}\u{435} \u{442}\u{43e}\u{447}\u{435}\u{43a} \u{43f}\u{43e}\u{43a}\u{430} \u{43d}\u{435}\u{442}. \u{421}\u{43e}\u{445}\u{440}\u{430}\u{43d}\u{438}\u{442}\u{435}: setwp <\u{438}\u{43c}\u{44f}>.'
,['chr.respawned']=
'\u{41f}\u{435}\u{440}\u{441}\u{43e}\u{43d}\u{430}\u{436} \u{432}\u{43e}\u{437}\u{440}\u{43e}\u{436}\u{434}\u{451}\u{43d}'
},uk={['c.fly']='\u{41f}\u{43e}\u{43b}\u{456}\u{442}',['d.fly']=
'\u{41b}\u{456}\u{442}\u{430}\u{442}\u{438}. WASD \u{2014} \u{440}\u{443}\u{445}, \u{43f}\u{440}\u{43e}\u{431}\u{456}\u{43b} \u{456} Ctrl \u{2014} \u{432}\u{438}\u{441}\u{43e}\u{442}\u{430}; \u{43d}\u{430} \u{442}\u{435}\u{43b}\u{435}\u{444}\u{43e}\u{43d}\u{456} \u{2014} \u{441}\u{442}\u{456}\u{43a} \u{456} \u{43a}\u{43d}\u{43e}\u{43f}\u{43a}\u{430} \u{441}\u{442}\u{440}\u{438}\u{431}\u{43a}\u{430}.'
,['c.flyspeed']=
'\u{428}\u{432}\u{438}\u{434}\u{43a}\u{456}\u{441}\u{442}\u{44c} \u{43f}\u{43e}\u{43b}\u{44c}\u{43e}\u{442}\u{443}',[
'd.flyspeed']=
'\u{417} \u{44f}\u{43a}\u{43e}\u{44e} \u{448}\u{432}\u{438}\u{434}\u{43a}\u{456}\u{441}\u{442}\u{44e} \u{43b}\u{456}\u{442}\u{430}\u{454} fly.'
,['c.noclip']='\u{41a}\u{440}\u{456}\u{437}\u{44c} \u{441}\u{442}\u{456}\u{43d}\u{438}',['d.noclip']=
'\u{41f}\u{440}\u{43e}\u{445}\u{43e}\u{434}\u{438}\u{442}\u{438} \u{43a}\u{440}\u{456}\u{437}\u{44c} \u{441}\u{442}\u{456}\u{43d}\u{438}. \u{41b}\u{438}\u{448}\u{435} \u{441}\u{432}\u{456}\u{439} \u{43f}\u{435}\u{440}\u{441}\u{43e}\u{43d}\u{430}\u{436}.'
,['c.speed']='\u{428}\u{432}\u{438}\u{434}\u{43a}\u{456}\u{441}\u{442}\u{44c}',['d.speed']=
'\u{428}\u{432}\u{438}\u{434}\u{43a}\u{456}\u{441}\u{442}\u{44c} \u{445}\u{43e}\u{434}\u{44c}\u{431}\u{438}. \u{411}\u{435}\u{437} \u{437}\u{43d}\u{430}\u{447}\u{435}\u{43d}\u{43d}\u{44f} \u{2014} \u{44f}\u{43a} \u{437}\u{430}\u{434}\u{430}\u{43b}\u{430} \u{433}\u{440}\u{430}.'
,['c.jumppower']='\u{421}\u{438}\u{43b}\u{430} \u{441}\u{442}\u{440}\u{438}\u{431}\u{43a}\u{430}',['d.jumppower']=
'\u{421}\u{438}\u{43b}\u{430} \u{441}\u{442}\u{440}\u{438}\u{431}\u{43a}\u{430}. \u{411}\u{435}\u{437} \u{437}\u{43d}\u{430}\u{447}\u{435}\u{43d}\u{43d}\u{44f} \u{2014} \u{44f}\u{43a} \u{437}\u{430}\u{434}\u{430}\u{43b}\u{430} \u{433}\u{440}\u{430}.'
,['c.infjump']=
'\u{41d}\u{435}\u{441}\u{43a}\u{456}\u{43d}\u{447}\u{435}\u{43d}\u{43d}\u{438}\u{439} \u{441}\u{442}\u{440}\u{438}\u{431}\u{43e}\u{43a}'
,['d.infjump']=
'\u{421}\u{442}\u{440}\u{438}\u{431}\u{430}\u{442}\u{438} \u{449}\u{435} \u{440}\u{430}\u{437} \u{43f}\u{440}\u{43e}\u{441}\u{442}\u{43e} \u{432} \u{43f}\u{43e}\u{432}\u{456}\u{442}\u{440}\u{456}.'
,['c.sit']='\u{421}\u{456}\u{441}\u{442}\u{438}',['d.sit']=
'\u{421}\u{456}\u{441}\u{442}\u{438} \u{43d}\u{430} \u{43c}\u{456}\u{441}\u{446}\u{456}.',['c.lay']=
'\u{41b}\u{44f}\u{433}\u{442}\u{438}',['d.lay']=
'\u{41b}\u{44f}\u{433}\u{442}\u{438} \u{43d}\u{430} \u{43c}\u{456}\u{441}\u{446}\u{456}.',['c.setwp']=
'\u{417}\u{431}\u{435}\u{440}\u{435}\u{433}\u{442}\u{438} \u{442}\u{43e}\u{447}\u{43a}\u{443}',['d.setwp']=
'\u{417}\u{431}\u{435}\u{440}\u{435}\u{433}\u{442}\u{438} \u{43f}\u{43e}\u{442}\u{43e}\u{447}\u{43d}\u{435} \u{43c}\u{456}\u{441}\u{446}\u{435} \u{44f}\u{43a} \u{442}\u{43e}\u{447}\u{43a}\u{443}. \u{422}\u{43e}\u{447}\u{43a}\u{438} \u{441}\u{432}\u{43e}\u{457} \u{434}\u{43b}\u{44f} \u{43a}\u{43e}\u{436}\u{43d}\u{43e}\u{433}\u{43e} \u{43f}\u{43b}\u{435}\u{439}\u{441}\u{443}.'
,['c.wp']='\u{414}\u{43e} \u{442}\u{43e}\u{447}\u{43a}\u{438}',['d.wp']=
'\u{41f}\u{435}\u{440}\u{435}\u{43c}\u{456}\u{441}\u{442}\u{438}\u{442}\u{438} \u{441}\u{432}\u{43e}\u{433}\u{43e} \u{43f}\u{435}\u{440}\u{441}\u{43e}\u{43d}\u{430}\u{436}\u{430} \u{434}\u{43e} \u{437}\u{431}\u{435}\u{440}\u{435}\u{436}\u{435}\u{43d}\u{43e}\u{457} \u{442}\u{43e}\u{447}\u{43a}\u{438}.'
,['c.delwp']='\u{412}\u{438}\u{434}\u{430}\u{43b}\u{438}\u{442}\u{438} \u{442}\u{43e}\u{447}\u{43a}\u{443}',['d.delwp']=
'\u{412}\u{438}\u{434}\u{430}\u{43b}\u{438}\u{442}\u{438} \u{437}\u{431}\u{435}\u{440}\u{435}\u{436}\u{435}\u{43d}\u{443} \u{442}\u{43e}\u{447}\u{43a}\u{443}.'
,['c.waypoints']='\u{422}\u{43e}\u{447}\u{43a}\u{438}',['d.waypoints']=
'\u{421}\u{43f}\u{438}\u{441}\u{43e}\u{43a} \u{442}\u{43e}\u{447}\u{43e}\u{43a} \u{446}\u{44c}\u{43e}\u{433}\u{43e} \u{43f}\u{43b}\u{435}\u{439}\u{441}\u{443}.'
,['c.antiafk']='\u{410}\u{43d}\u{442}\u{438}-\u{410}\u{424}\u{41a}',['d.antiafk']=
'\u{413}\u{440}\u{430} \u{43d}\u{435} \u{432}\u{438}\u{43a}\u{438}\u{43d}\u{435} \u{437}\u{430} \u{431}\u{435}\u{437}\u{434}\u{456}\u{44f}\u{43b}\u{44c}\u{43d}\u{456}\u{441}\u{442}\u{44c}.'
,['c.respawn']='\u{412}\u{456}\u{434}\u{440}\u{43e}\u{434}\u{438}\u{442}\u{438}\u{441}\u{44f}',['d.respawn']=
'\u{412}\u{456}\u{434}\u{440}\u{43e}\u{434}\u{438}\u{442}\u{438} \u{441}\u{432}\u{43e}\u{433}\u{43e} \u{43f}\u{435}\u{440}\u{441}\u{43e}\u{43d}\u{430}\u{436}\u{430}.'
,['c.refresh']='\u{41e}\u{43d}\u{43e}\u{432}\u{438}\u{442}\u{438}',['d.refresh']=
'\u{412}\u{456}\u{434}\u{440}\u{43e}\u{434}\u{438}\u{442}\u{438}\u{441}\u{44f} \u{439} \u{43f}\u{43e}\u{432}\u{435}\u{440}\u{43d}\u{443}\u{442}\u{438}\u{441}\u{44f} \u{43d}\u{430} \u{442}\u{435} \u{441}\u{430}\u{43c}\u{435} \u{43c}\u{456}\u{441}\u{446}\u{435}.'
,['chr.no_character']=
'\u{41f}\u{435}\u{440}\u{441}\u{43e}\u{43d}\u{430}\u{436} \u{449}\u{435} \u{43d}\u{435} \u{437}\u{430}\u{432}\u{430}\u{43d}\u{442}\u{430}\u{436}\u{438}\u{432}\u{441}\u{44f}'
,['chr.wp_saved']=
'\u{422}\u{43e}\u{447}\u{43a}\u{443} \u{ab}%s\u{bb} \u{437}\u{431}\u{435}\u{440}\u{435}\u{436}\u{435}\u{43d}\u{43e}',[
'chr.wp_moved']='\u{412}\u{438} \u{431}\u{456}\u{43b}\u{44f} \u{442}\u{43e}\u{447}\u{43a}\u{438} \u{ab}%s\u{bb}',[
'chr.wp_deleted']=
'\u{422}\u{43e}\u{447}\u{43a}\u{443} \u{ab}%s\u{bb} \u{432}\u{438}\u{434}\u{430}\u{43b}\u{435}\u{43d}\u{43e}',[
'chr.wp_list']='\u{422}\u{43e}\u{447}\u{43a}\u{438}: %s',['chr.wp_none']=
'\u{423} \u{446}\u{44c}\u{43e}\u{43c}\u{443} \u{43f}\u{43b}\u{435}\u{439}\u{441}\u{456} \u{442}\u{43e}\u{447}\u{43e}\u{43a} \u{43f}\u{43e}\u{43a}\u{438} \u{43d}\u{435}\u{43c}\u{430}\u{454}. \u{417}\u{431}\u{435}\u{440}\u{435}\u{436}\u{456}\u{442}\u{44c}: setwp <\u{43d}\u{430}\u{437}\u{432}\u{430}>.'
,['chr.respawned']=
'\u{41f}\u{435}\u{440}\u{441}\u{43e}\u{43d}\u{430}\u{436}\u{430} \u{432}\u{456}\u{434}\u{440}\u{43e}\u{434}\u{436}\u{435}\u{43d}\u{43e}'
},es={['c.fly']='Volar',['d.fly']=
'Volar. WASD para moverte, Espacio y Ctrl para la altura; en el m\u{f3}vil, el joystick y el bot\u{f3}n de salto.',[
'c.flyspeed']='Velocidad de vuelo',['d.flyspeed']='Qu\u{e9} tan r\u{e1}pido vuela fly.',['c.noclip']='Atravesar paredes'
,['d.noclip']='Atraviesa paredes. Solo tu personaje.',['c.speed']='Velocidad',['d.speed']=
'Velocidad al caminar. Sin valor vuelve a la del juego.',['c.jumppower']='Fuerza de salto',['d.jumppower']=
'Fuerza de salto. Sin valor vuelve a la del juego.',['c.infjump']='Salto infinito',['d.infjump']=
'Vuelve a saltar en el aire.',['c.sit']='Sentarse',['d.sit']='Si\u{e9}ntate donde est\u{e1}s.',['c.lay']='Tumbarse',[
'd.lay']='T\u{fa}mbate donde est\u{e1}s.',['c.setwp']='Guardar punto',['d.setwp']=
'Guarda tu posici\u{f3}n como punto. Los puntos se guardan por juego.',['c.wp']='Ir al punto',['d.wp']=
'Lleva a tu personaje a un punto guardado.',['c.delwp']='Borrar punto',['d.delwp']='Borra un punto guardado.',[
'c.waypoints']='Puntos',['d.waypoints']='Lista los puntos de este juego.',['c.antiafk']='Anti-AFK',['d.antiafk']=
'Evita que el juego te expulse por inactividad.',['c.respawn']='Reaparecer',['d.respawn']=
'Hace reaparecer a tu personaje.',['c.refresh']='Refrescar',['d.refresh']='Reaparece y vuelve al mismo sitio.',[
'chr.no_character']='Tu personaje a\u{fa}n no ha cargado',['chr.wp_saved']='Punto \u{ab}%s\u{bb} guardado',[
'chr.wp_moved']='Est\u{e1}s en \u{ab}%s\u{bb}',['chr.wp_deleted']='Punto \u{ab}%s\u{bb} borrado',['chr.wp_list']=
'Puntos: %s',['chr.wp_none']='A\u{fa}n no hay puntos en este juego. Guarda uno con setwp <nombre>.',['chr.respawned']=
'Has reaparecido'},pt={['c.fly']='Voar',['d.fly']=
'Voar. WASD para mover, Espa\u{e7}o e Ctrl para a altura; no celular, o anal\u{f3}gico e o bot\u{e3}o de pulo.',[
'c.flyspeed']='Velocidade de voo',['d.flyspeed']='A velocidade do fly.',['c.noclip']='Atravessar paredes',['d.noclip']=
'Atravessa paredes. S\u{f3} o seu personagem.',['c.speed']='Velocidade',['d.speed']=
'Velocidade ao andar. Sem valor volta \u{e0} do jogo.',['c.jumppower']='For\u{e7}a do pulo',['d.jumppower']=
'For\u{e7}a do pulo. Sem valor volta \u{e0} do jogo.',['c.infjump']='Pulo infinito',['d.infjump']='Pula de novo no ar.',
['c.sit']='Sentar',['d.sit']='Senta onde voc\u{ea} est\u{e1}.',['c.lay']='Deitar',['d.lay']=
'Deita onde voc\u{ea} est\u{e1}.',['c.setwp']='Salvar ponto',['d.setwp']=
'Salva onde voc\u{ea} est\u{e1} como ponto. Os pontos ficam por jogo.',['c.wp']='Ir ao ponto',['d.wp']=
'Leva seu personagem a um ponto salvo.',['c.delwp']='Apagar ponto',['d.delwp']='Apaga um ponto salvo.',['c.waypoints']=
'Pontos',['d.waypoints']='Lista os pontos deste jogo.',['c.antiafk']='Anti-AFK',['d.antiafk']=
'Impede que o jogo te expulse por ficar parado.',['c.respawn']='Renascer',['d.respawn']='Faz seu personagem renascer.',[
'c.refresh']='Atualizar',['d.refresh']='Renasce e volta ao mesmo lugar.',['chr.no_character']=
'Seu personagem ainda n\u{e3}o carregou',['chr.wp_saved']='Ponto \u{201c}%s\u{201d} salvo',['chr.wp_moved']=
'Voc\u{ea} est\u{e1} em \u{201c}%s\u{201d}',['chr.wp_deleted']='Ponto \u{201c}%s\u{201d} apagado',['chr.wp_list']=
'Pontos: %s',['chr.wp_none']='Ainda n\u{e3}o h\u{e1} pontos neste jogo. Salve um com setwp <nome>.',['chr.respawned']=
'Voc\u{ea} renasceu'},de={['c.fly']='Fliegen',['d.fly']=
'Fliegen. WASD zum Bewegen, Leertaste und Strg f\u{fc}r die H\u{f6}he; am Handy Stick und Sprungtaste.',['c.flyspeed']=
'Fluggeschwindigkeit',['d.flyspeed']='Wie schnell fly fliegt.',['c.noclip']='Durch W\u{e4}nde',['d.noclip']=
'Durch W\u{e4}nde gehen. Nur dein eigener Charakter.',['c.speed']='Laufgeschwindigkeit',['d.speed']=
'Laufgeschwindigkeit. Ohne Wert wieder die des Spiels.',['c.jumppower']='Sprungkraft',['d.jumppower']=
'Sprungkraft. Ohne Wert wieder die des Spiels.',['c.infjump']='Endlos springen',['d.infjump']=
'In der Luft erneut springen.',['c.sit']='Hinsetzen',['d.sit']='Setz dich hin, wo du stehst.',['c.lay']='Hinlegen',[
'd.lay']='Leg dich hin, wo du stehst.',['c.setwp']='Wegpunkt speichern',['d.setwp']=
[[Speichert deinen Standort als Wegpunkt. Wegpunkte gelten pro Spiel.]],['c.wp']='Zum Wegpunkt',['d.wp']=
'Bringt deinen Charakter zu einem gespeicherten Wegpunkt.',['c.delwp']='Wegpunkt l\u{f6}schen',['d.delwp']=
'L\u{f6}scht einen gespeicherten Wegpunkt.',['c.waypoints']='Wegpunkte',['d.waypoints']=
'Listet die Wegpunkte dieses Spiels.',['c.antiafk']='Anti-AFK',['d.antiafk']=
'Verhindert, dass das Spiel dich wegen Inaktivit\u{e4}t kickt.',['c.respawn']='Respawn',['d.respawn']=
'L\u{e4}sst deinen Charakter neu erscheinen.',['c.refresh']='Auffrischen',['d.refresh']=
'Neu erscheinen und an dieselbe Stelle zur\u{fc}ck.',['chr.no_character']='Dein Charakter ist noch nicht geladen',[
'chr.wp_saved']='Wegpunkt \u{201e}%s\u{201c} gespeichert',['chr.wp_moved']='Du bist bei \u{201e}%s\u{201c}',[
'chr.wp_deleted']='Wegpunkt \u{201e}%s\u{201c} gel\u{f6}scht',['chr.wp_list']='Wegpunkte: %s',['chr.wp_none']=
[[Noch keine Wegpunkte in diesem Spiel. Speichere einen mit setwp <name>.]],['chr.respawned']='Neu erschienen'}}return
bundle end function __DARKLUA_BUNDLE_MODULES.W()local v=__DARKLUA_BUNDLE_MODULES.cache.W if not v then v={c=__modImpl()}
__DARKLUA_BUNDLE_MODULES.cache.W=v end return v.c end end do local function __modImpl()local Types=
__DARKLUA_BUNDLE_MODULES.c()local bundle={en={['c.help']='Help',['d.help']='List commands, or show help for one.',[
'c.bind']='Bind key',['d.bind']='Bind a command line to a key.',['c.unbind']='Unbind key',['d.unbind']=
'Remove a key bind.',['c.binds']='Binds',['d.binds']='Show key binds.',['c.togglekey']='Window key',['d.togglekey']=
[[Key that shows and hides the window. Without a key it goes back to RightShift.]],['c.lang']='Language',['d.lang']=
'Interface language.',['c.enable']='Enable command',['d.enable']='Allow a disabled command again.',['c.disable']=
'Disable command',['d.disable']='Hide a command from the list, the command line and binds.',['c.settings']='Settings',[
'd.settings']='Open settings.',['c.log']='Log',['d.log']='Open the hub log.',['c.unload']='Turn off',['d.unload']=
'Turn the hub off and undo everything it changed.',['help.count']='%d commands. Type a name to see what it does.',[
'help.one']='%s \u{2014} %s',['hub.no_bind']='Nothing is bound to %s',['hub.togglekey']='Window key: %s'},ru={['c.help']
='\u{421}\u{43f}\u{440}\u{430}\u{432}\u{43a}\u{430}',['d.help']=
'\u{421}\u{43f}\u{438}\u{441}\u{43e}\u{43a} \u{43a}\u{43e}\u{43c}\u{430}\u{43d}\u{434} \u{438}\u{43b}\u{438} \u{441}\u{43f}\u{440}\u{430}\u{432}\u{43a}\u{430} \u{43f}\u{43e} \u{43e}\u{434}\u{43d}\u{43e}\u{439}.'
,['c.bind']='\u{411}\u{438}\u{43d}\u{434}',['d.bind']=
'\u{41f}\u{440}\u{438}\u{432}\u{44f}\u{437}\u{430}\u{442}\u{44c} \u{441}\u{442}\u{440}\u{43e}\u{43a}\u{443} \u{43a}\u{43e}\u{43c}\u{430}\u{43d}\u{434}\u{44b} \u{43a} \u{43a}\u{43b}\u{430}\u{432}\u{438}\u{448}\u{435}.'
,['c.unbind']='\u{421}\u{43d}\u{44f}\u{442}\u{44c} \u{431}\u{438}\u{43d}\u{434}',['d.unbind']=
'\u{423}\u{431}\u{440}\u{430}\u{442}\u{44c} \u{431}\u{438}\u{43d}\u{434} \u{441} \u{43a}\u{43b}\u{430}\u{432}\u{438}\u{448}\u{438}.'
,['c.binds']='\u{411}\u{438}\u{43d}\u{434}\u{44b}',['d.binds']=
'\u{41f}\u{43e}\u{43a}\u{430}\u{437}\u{430}\u{442}\u{44c} \u{431}\u{438}\u{43d}\u{434}\u{44b}.',['c.togglekey']=
'\u{41a}\u{43b}\u{430}\u{432}\u{438}\u{448}\u{430} \u{43e}\u{43a}\u{43d}\u{430}',['d.togglekey']=
'\u{41a}\u{43b}\u{430}\u{432}\u{438}\u{448}\u{430} \u{43f}\u{43e}\u{43a}\u{430}\u{437}\u{430} \u{43e}\u{43a}\u{43d}\u{430}. \u{411}\u{435}\u{437} \u{430}\u{440}\u{433}\u{443}\u{43c}\u{435}\u{43d}\u{442}\u{430} \u{2014} \u{441}\u{43d}\u{43e}\u{432}\u{430} RightShift.'
,['c.lang']='\u{42f}\u{437}\u{44b}\u{43a}',['d.lang']=
'\u{42f}\u{437}\u{44b}\u{43a} \u{438}\u{43d}\u{442}\u{435}\u{440}\u{444}\u{435}\u{439}\u{441}\u{430}.',['c.enable']=
'\u{412}\u{43a}\u{43b}\u{44e}\u{447}\u{438}\u{442}\u{44c} \u{43a}\u{43e}\u{43c}\u{430}\u{43d}\u{434}\u{443}',['d.enable'
]=
'\u{421}\u{43d}\u{43e}\u{432}\u{430} \u{440}\u{430}\u{437}\u{440}\u{435}\u{448}\u{438}\u{442}\u{44c} \u{432}\u{44b}\u{43a}\u{43b}\u{44e}\u{447}\u{435}\u{43d}\u{43d}\u{443}\u{44e} \u{43a}\u{43e}\u{43c}\u{430}\u{43d}\u{434}\u{443}.'
,['c.disable']=
'\u{412}\u{44b}\u{43a}\u{43b}\u{44e}\u{447}\u{438}\u{442}\u{44c} \u{43a}\u{43e}\u{43c}\u{430}\u{43d}\u{434}\u{443}',[
'd.disable']=
'\u{423}\u{431}\u{440}\u{430}\u{442}\u{44c} \u{43a}\u{43e}\u{43c}\u{430}\u{43d}\u{434}\u{443} \u{438}\u{437} \u{441}\u{43f}\u{438}\u{441}\u{43a}\u{430}, \u{441}\u{442}\u{440}\u{43e}\u{43a}\u{438} \u{43a}\u{43e}\u{43c}\u{430}\u{43d}\u{434} \u{438} \u{431}\u{438}\u{43d}\u{434}\u{43e}\u{432}.'
,['c.settings']='\u{41d}\u{430}\u{441}\u{442}\u{440}\u{43e}\u{439}\u{43a}\u{438}',['d.settings']=
'\u{41e}\u{442}\u{43a}\u{440}\u{44b}\u{442}\u{44c} \u{43d}\u{430}\u{441}\u{442}\u{440}\u{43e}\u{439}\u{43a}\u{438}.',[
'c.log']='\u{41b}\u{43e}\u{433}',['d.log']=
'\u{41e}\u{442}\u{43a}\u{440}\u{44b}\u{442}\u{44c} \u{43b}\u{43e}\u{433} \u{445}\u{430}\u{431}\u{430}.',['c.unload']=
'\u{412}\u{44b}\u{43a}\u{43b}\u{44e}\u{447}\u{438}\u{442}\u{44c}',['d.unload']=
'\u{412}\u{44b}\u{43a}\u{43b}\u{44e}\u{447}\u{438}\u{442}\u{44c} \u{445}\u{430}\u{431} \u{438} \u{432}\u{435}\u{440}\u{43d}\u{443}\u{442}\u{44c} \u{432}\u{441}\u{451}, \u{447}\u{442}\u{43e} \u{43e}\u{43d} \u{43c}\u{435}\u{43d}\u{44f}\u{43b}.'
,['help.count']=
'\u{41a}\u{43e}\u{43c}\u{430}\u{43d}\u{434}: %d. \u{41d}\u{430}\u{447}\u{43d}\u{438}\u{442}\u{435} \u{432}\u{432}\u{43e}\u{434}\u{438}\u{442}\u{44c} \u{438}\u{43c}\u{44f}, \u{447}\u{442}\u{43e}\u{431}\u{44b} \u{443}\u{432}\u{438}\u{434}\u{435}\u{442}\u{44c} \u{43e}\u{43f}\u{438}\u{441}\u{430}\u{43d}\u{438}\u{435}.'
,['help.one']='%s \u{2014} %s',['hub.no_bind']=
'\u{41d}\u{430} %s \u{43d}\u{438}\u{447}\u{435}\u{433}\u{43e} \u{43d}\u{435} \u{43d}\u{430}\u{437}\u{43d}\u{430}\u{447}\u{435}\u{43d}\u{43e}'
,['hub.togglekey']='\u{41a}\u{43b}\u{430}\u{432}\u{438}\u{448}\u{430} \u{43e}\u{43a}\u{43d}\u{430}: %s'},uk={['c.help']=
'\u{414}\u{43e}\u{432}\u{456}\u{434}\u{43a}\u{430}',['d.help']=
'\u{421}\u{43f}\u{438}\u{441}\u{43e}\u{43a} \u{43a}\u{43e}\u{43c}\u{430}\u{43d}\u{434} \u{430}\u{431}\u{43e} \u{434}\u{43e}\u{432}\u{456}\u{434}\u{43a}\u{430} \u{43f}\u{440}\u{43e} \u{43e}\u{434}\u{43d}\u{443}.'
,['c.bind']='\u{411}\u{456}\u{43d}\u{434}',['d.bind']=
'\u{41f}\u{440}\u{438}\u{432}\u{2019}\u{44f}\u{437}\u{430}\u{442}\u{438} \u{440}\u{44f}\u{434}\u{43e}\u{43a} \u{43a}\u{43e}\u{43c}\u{430}\u{43d}\u{434}\u{438} \u{434}\u{43e} \u{43a}\u{43b}\u{430}\u{432}\u{456}\u{448}\u{456}.'
,['c.unbind']='\u{417}\u{43d}\u{44f}\u{442}\u{438} \u{431}\u{456}\u{43d}\u{434}',['d.unbind']=
'\u{41f}\u{440}\u{438}\u{431}\u{440}\u{430}\u{442}\u{438} \u{431}\u{456}\u{43d}\u{434} \u{437} \u{43a}\u{43b}\u{430}\u{432}\u{456}\u{448}\u{456}.'
,['c.binds']='\u{411}\u{456}\u{43d}\u{434}\u{438}',['d.binds']=
'\u{41f}\u{43e}\u{43a}\u{430}\u{437}\u{430}\u{442}\u{438} \u{431}\u{456}\u{43d}\u{434}\u{438}.',['c.togglekey']=
'\u{41a}\u{43b}\u{430}\u{432}\u{456}\u{448}\u{430} \u{432}\u{456}\u{43a}\u{43d}\u{430}',['d.togglekey']=
'\u{41a}\u{43b}\u{430}\u{432}\u{456}\u{448}\u{430} \u{43f}\u{43e}\u{43a}\u{430}\u{437}\u{443} \u{432}\u{456}\u{43a}\u{43d}\u{430}. \u{411}\u{435}\u{437} \u{430}\u{440}\u{433}\u{443}\u{43c}\u{435}\u{43d}\u{442}\u{443} \u{2014} \u{437}\u{43d}\u{43e}\u{432}\u{443} RightShift.'
,['c.lang']='\u{41c}\u{43e}\u{432}\u{430}',['d.lang']=
'\u{41c}\u{43e}\u{432}\u{430} \u{456}\u{43d}\u{442}\u{435}\u{440}\u{444}\u{435}\u{439}\u{441}\u{443}.',['c.enable']=
'\u{423}\u{432}\u{456}\u{43c}\u{43a}\u{43d}\u{443}\u{442}\u{438} \u{43a}\u{43e}\u{43c}\u{430}\u{43d}\u{434}\u{443}',[
'd.enable']=
'\u{417}\u{43d}\u{43e}\u{432}\u{443} \u{434}\u{43e}\u{437}\u{432}\u{43e}\u{43b}\u{438}\u{442}\u{438} \u{432}\u{438}\u{43c}\u{43a}\u{43d}\u{435}\u{43d}\u{443} \u{43a}\u{43e}\u{43c}\u{430}\u{43d}\u{434}\u{443}.'
,['c.disable']=
'\u{412}\u{438}\u{43c}\u{43a}\u{43d}\u{443}\u{442}\u{438} \u{43a}\u{43e}\u{43c}\u{430}\u{43d}\u{434}\u{443}',[
'd.disable']=
'\u{41f}\u{440}\u{438}\u{431}\u{440}\u{430}\u{442}\u{438} \u{43a}\u{43e}\u{43c}\u{430}\u{43d}\u{434}\u{443} \u{437}\u{456} \u{441}\u{43f}\u{438}\u{441}\u{43a}\u{443}, \u{440}\u{44f}\u{434}\u{43a}\u{430} \u{43a}\u{43e}\u{43c}\u{430}\u{43d}\u{434} \u{456} \u{431}\u{456}\u{43d}\u{434}\u{456}\u{432}.'
,['c.settings']='\u{41d}\u{430}\u{43b}\u{430}\u{448}\u{442}\u{443}\u{432}\u{430}\u{43d}\u{43d}\u{44f}',['d.settings']=
'\u{412}\u{456}\u{434}\u{43a}\u{440}\u{438}\u{442}\u{438} \u{43d}\u{430}\u{43b}\u{430}\u{448}\u{442}\u{443}\u{432}\u{430}\u{43d}\u{43d}\u{44f}.'
,['c.log']='\u{41b}\u{43e}\u{433}',['d.log']=
'\u{412}\u{456}\u{434}\u{43a}\u{440}\u{438}\u{442}\u{438} \u{43b}\u{43e}\u{433} \u{445}\u{430}\u{431}\u{430}.',[
'c.unload']='\u{412}\u{438}\u{43c}\u{43a}\u{43d}\u{443}\u{442}\u{438}',['d.unload']=
'\u{412}\u{438}\u{43c}\u{43a}\u{43d}\u{443}\u{442}\u{438} \u{445}\u{430}\u{431} \u{456} \u{43f}\u{43e}\u{432}\u{435}\u{440}\u{43d}\u{443}\u{442}\u{438} \u{432}\u{441}\u{435}, \u{449}\u{43e} \u{432}\u{456}\u{43d} \u{437}\u{43c}\u{456}\u{43d}\u{44e}\u{432}\u{430}\u{432}.'
,['help.count']=
'\u{41a}\u{43e}\u{43c}\u{430}\u{43d}\u{434}: %d. \u{41f}\u{43e}\u{447}\u{43d}\u{456}\u{442}\u{44c} \u{432}\u{432}\u{43e}\u{434}\u{438}\u{442}\u{438} \u{43d}\u{430}\u{437}\u{432}\u{443}, \u{449}\u{43e}\u{431} \u{43f}\u{43e}\u{431}\u{430}\u{447}\u{438}\u{442}\u{438} \u{43e}\u{43f}\u{438}\u{441}.'
,['help.one']='%s \u{2014} %s',['hub.no_bind']=
'\u{41d}\u{430} %s \u{43d}\u{456}\u{447}\u{43e}\u{433}\u{43e} \u{43d}\u{435} \u{43f}\u{440}\u{438}\u{437}\u{43d}\u{430}\u{447}\u{435}\u{43d}\u{43e}'
,['hub.togglekey']='\u{41a}\u{43b}\u{430}\u{432}\u{456}\u{448}\u{430} \u{432}\u{456}\u{43a}\u{43d}\u{430}: %s'},es={[
'c.help']='Ayuda',['d.help']='Lista de comandos o ayuda sobre uno.',['c.bind']='Asignar tecla',['d.bind']=
'Asigna una l\u{ed}nea de comando a una tecla.',['c.unbind']='Quitar tecla',['d.unbind']=
'Quita la asignaci\u{f3}n de una tecla.',['c.binds']='Atajos',['d.binds']='Muestra los atajos.',['c.togglekey']=
'Tecla de ventana',['d.togglekey']=[[Tecla que muestra y oculta la ventana. Sin tecla vuelve a RightShift.]],['c.lang']=
'Idioma',['d.lang']='Idioma de la interfaz.',['c.enable']='Activar comando',['d.enable']=
'Vuelve a permitir un comando desactivado.',['c.disable']='Desactivar comando',['d.disable']=
'Oculta un comando de la lista, la l\u{ed}nea de comandos y los atajos.',['c.settings']='Ajustes',['d.settings']=
'Abre los ajustes.',['c.log']='Registro',['d.log']='Abre el registro del hub.',['c.unload']='Apagar',['d.unload']=
'Apaga el hub y deshace todo lo que cambi\u{f3}.',['help.count']=
'%d comandos. Escribe un nombre para ver qu\u{e9} hace.',['help.one']='%s \u{2014} %s',['hub.no_bind']=
'%s no tiene nada asignado',['hub.togglekey']='Tecla de ventana: %s'},pt={['c.help']='Ajuda',['d.help']=
'Lista de comandos ou ajuda sobre um.',['c.bind']='Definir atalho',['d.bind']='Liga uma linha de comando a uma tecla.',[
'c.unbind']='Remover atalho',['d.unbind']='Remove o atalho de uma tecla.',['c.binds']='Atalhos',['d.binds']=
'Mostra os atalhos.',['c.togglekey']='Tecla da janela',['d.togglekey']=
[[Tecla que mostra e oculta a janela. Sem tecla volta para RightShift.]],['c.lang']='Idioma',['d.lang']=
'Idioma da interface.',['c.enable']='Ativar comando',['d.enable']='Permite de novo um comando desativado.',['c.disable']
='Desativar comando',['d.disable']=[[Tira um comando da lista, da linha de comando e dos atalhos.]],['c.settings']=
'Configura\u{e7}\u{f5}es',['d.settings']='Abre as configura\u{e7}\u{f5}es.',['c.log']='Registro',['d.log']=
'Abre o registro do hub.',['c.unload']='Desligar',['d.unload']='Desliga o hub e desfaz tudo o que ele mudou.',[
'help.count']='%d comandos. Digite um nome para ver o que faz.',['help.one']='%s \u{2014} %s',['hub.no_bind']=
'Nada ligado a %s',['hub.togglekey']='Tecla da janela: %s'},de={['c.help']='Hilfe',['d.help']=
'Befehle auflisten oder Hilfe zu einem zeigen.',['c.bind']='Taste belegen',['d.bind']=
'Eine Befehlszeile auf eine Taste legen.',['c.unbind']='Belegung entfernen',['d.unbind']=
'Die Belegung einer Taste entfernen.',['c.binds']='Belegungen',['d.binds']='Tastenbelegungen zeigen.',['c.togglekey']=
'Fenstertaste',['d.togglekey']=[[Taste zum Ein- und Ausblenden des Fensters. Ohne Taste wieder RightShift.]],['c.lang']=
'Sprache',['d.lang']='Sprache der Oberfl\u{e4}che.',['c.enable']='Befehl aktivieren',['d.enable']=
'Einen deaktivierten Befehl wieder erlauben.',['c.disable']='Befehl deaktivieren',['d.disable']=
'Einen Befehl aus Liste, Befehlszeile und Belegungen nehmen.',['c.settings']='Einstellungen',['d.settings']=
'Einstellungen \u{f6}ffnen.',['c.log']='Protokoll',['d.log']='Das Hub-Protokoll \u{f6}ffnen.',['c.unload']='Ausschalten'
,['d.unload']='Den Hub ausschalten und alles r\u{fc}ckg\u{e4}ngig machen, was er ge\u{e4}ndert hat.',['help.count']=
'%d Befehle. Tippe einen Namen, um zu sehen, was er tut.',['help.one']='%s \u{2014} %s',['hub.no_bind']=
'Auf %s liegt nichts',['hub.togglekey']='Fenstertaste: %s'}}return bundle end function __DARKLUA_BUNDLE_MODULES.X()local
v=__DARKLUA_BUNDLE_MODULES.cache.X if not v then v={c=__modImpl()}__DARKLUA_BUNDLE_MODULES.cache.X=v end return v.c end
end do local function __modImpl()local Types=__DARKLUA_BUNDLE_MODULES.c()local bundle={en={['md.search']=
'Search the module',['sp.modules']='Modules',['md.presets']='Sets',['md.save']='Save current',['md.my_preset']=
'My set %d',['md.saved']='Set saved',['md.all_off']='Turn all off',['md.section_on']='All on',['md.section_off']=
'All off',['md.params']='Section settings',['md.found']='Found: %d',['md.of']='%d of %d on',['md.start']='Start',[
'md.pause']='Pause',['md.resume']='Resume',['md.stop']='Stop',['md.running']='Running',['md.paused']='Paused',['md.none'
]='No modules for this place',['md.preset_on']='Set on: %s',['md.preset_off']='Set off: %s',['c.module']='Module',[
'd.module']='Open a game module: dozens of features, sets and a routine.',['c.preset']='Set',['d.preset']=
"Turn a module's set of features on or off.",['arg.module']='no module \u{201c}%s\u{201d}',['arg.preset']=
'no set \u{201c}%s\u{201d}'},ru={['md.search']=
'\u{41f}\u{43e}\u{438}\u{441}\u{43a} \u{43f}\u{43e} \u{43c}\u{43e}\u{434}\u{443}\u{43b}\u{44e}',['sp.modules']=
'\u{41c}\u{43e}\u{434}\u{443}\u{43b}\u{438}',['md.presets']='\u{41d}\u{430}\u{431}\u{43e}\u{440}\u{44b}',['md.save']=
'\u{421}\u{43e}\u{445}\u{440}\u{430}\u{43d}\u{438}\u{442}\u{44c} \u{442}\u{435}\u{43a}\u{443}\u{449}\u{435}\u{435}',[
'md.my_preset']='\u{41c}\u{43e}\u{439} \u{43d}\u{430}\u{431}\u{43e}\u{440} %d',['md.saved']=
'\u{41d}\u{430}\u{431}\u{43e}\u{440} \u{441}\u{43e}\u{445}\u{440}\u{430}\u{43d}\u{451}\u{43d}',['md.all_off']=
'\u{412}\u{44b}\u{43a}\u{43b}\u{44e}\u{447}\u{438}\u{442}\u{44c} \u{432}\u{441}\u{451}',['md.section_on']=
'\u{412}\u{43a}\u{43b} \u{432}\u{441}\u{435}',['md.section_off']='\u{412}\u{44b}\u{43a}\u{43b} \u{432}\u{441}\u{435}',[
'md.params']=
'\u{41f}\u{430}\u{440}\u{430}\u{43c}\u{435}\u{442}\u{440}\u{44b} \u{440}\u{430}\u{437}\u{434}\u{435}\u{43b}\u{430}',[
'md.found']='\u{41d}\u{430}\u{439}\u{434}\u{435}\u{43d}\u{43e}: %d',['md.of']=
'%d \u{438}\u{437} %d \u{432}\u{43a}\u{43b}',['md.start']='\u{421}\u{442}\u{430}\u{440}\u{442}',['md.pause']=
'\u{41f}\u{430}\u{443}\u{437}\u{430}',['md.resume']=
'\u{41f}\u{440}\u{43e}\u{434}\u{43e}\u{43b}\u{436}\u{438}\u{442}\u{44c}',['md.stop']='\u{421}\u{442}\u{43e}\u{43f}',[
'md.running']='\u{420}\u{430}\u{431}\u{43e}\u{442}\u{430}\u{435}\u{442}',['md.paused']=
'\u{41d}\u{430} \u{43f}\u{430}\u{443}\u{437}\u{435}',['md.none']=
'\u{414}\u{43b}\u{44f} \u{44d}\u{442}\u{43e}\u{433}\u{43e} \u{43f}\u{43b}\u{435}\u{439}\u{441}\u{430} \u{43c}\u{43e}\u{434}\u{443}\u{43b}\u{435}\u{439} \u{43d}\u{435}\u{442}'
,['md.preset_on']='\u{41d}\u{430}\u{431}\u{43e}\u{440} \u{432}\u{43a}\u{43b}\u{44e}\u{447}\u{451}\u{43d}: %s',[
'md.preset_off']='\u{41d}\u{430}\u{431}\u{43e}\u{440} \u{432}\u{44b}\u{43a}\u{43b}\u{44e}\u{447}\u{435}\u{43d}: %s',[
'c.module']='\u{41c}\u{43e}\u{434}\u{443}\u{43b}\u{44c}',['d.module']=
'\u{41e}\u{442}\u{43a}\u{440}\u{44b}\u{442}\u{44c} \u{438}\u{433}\u{440}\u{43e}\u{432}\u{43e}\u{439} \u{43c}\u{43e}\u{434}\u{443}\u{43b}\u{44c}: \u{434}\u{435}\u{441}\u{44f}\u{442}\u{43a}\u{438} \u{444}\u{443}\u{43d}\u{43a}\u{446}\u{438}\u{439}, \u{43d}\u{430}\u{431}\u{43e}\u{440}\u{44b} \u{438} \u{441}\u{446}\u{435}\u{43d}\u{430}\u{440}\u{438}\u{439}.'
,['c.preset']='\u{41d}\u{430}\u{431}\u{43e}\u{440}',['d.preset']=
'\u{412}\u{43a}\u{43b}\u{44e}\u{447}\u{438}\u{442}\u{44c} \u{438}\u{43b}\u{438} \u{432}\u{44b}\u{43a}\u{43b}\u{44e}\u{447}\u{438}\u{442}\u{44c} \u{43d}\u{430}\u{431}\u{43e}\u{440} \u{444}\u{443}\u{43d}\u{43a}\u{446}\u{438}\u{439} \u{43c}\u{43e}\u{434}\u{443}\u{43b}\u{44f}.'
,['arg.module']='\u{43d}\u{435}\u{442} \u{43c}\u{43e}\u{434}\u{443}\u{43b}\u{44f} \u{ab}%s\u{bb}',['arg.preset']=
'\u{43d}\u{435}\u{442} \u{43d}\u{430}\u{431}\u{43e}\u{440}\u{430} \u{ab}%s\u{bb}'},uk={['md.search']=
'\u{41f}\u{43e}\u{448}\u{443}\u{43a} \u{443} \u{43c}\u{43e}\u{434}\u{443}\u{43b}\u{456}',['sp.modules']=
'\u{41c}\u{43e}\u{434}\u{443}\u{43b}\u{456}',['md.presets']='\u{41d}\u{430}\u{431}\u{43e}\u{440}\u{438}',['md.save']=
'\u{417}\u{431}\u{435}\u{440}\u{435}\u{433}\u{442}\u{438} \u{43f}\u{43e}\u{442}\u{43e}\u{447}\u{43d}\u{435}',[
'md.my_preset']='\u{41c}\u{456}\u{439} \u{43d}\u{430}\u{431}\u{456}\u{440} %d',['md.saved']=
'\u{41d}\u{430}\u{431}\u{456}\u{440} \u{437}\u{431}\u{435}\u{440}\u{435}\u{436}\u{435}\u{43d}\u{43e}',['md.all_off']=
'\u{412}\u{438}\u{43c}\u{43a}\u{43d}\u{443}\u{442}\u{438} \u{432}\u{441}\u{435}',['md.section_on']=
'\u{423}\u{432}\u{456}\u{43c}\u{43a}. \u{432}\u{441}\u{456}',['md.section_off']=
'\u{412}\u{438}\u{43c}\u{43a}. \u{432}\u{441}\u{456}',['md.params']=
'\u{41f}\u{430}\u{440}\u{430}\u{43c}\u{435}\u{442}\u{440}\u{438} \u{440}\u{43e}\u{437}\u{434}\u{456}\u{43b}\u{443}',[
'md.found']='\u{417}\u{43d}\u{430}\u{439}\u{434}\u{435}\u{43d}\u{43e}: %d',['md.of']=
'%d \u{437} %d \u{443}\u{432}\u{456}\u{43c}\u{43a}.',['md.start']='\u{421}\u{442}\u{430}\u{440}\u{442}',['md.pause']=
'\u{41f}\u{430}\u{443}\u{437}\u{430}',['md.resume']=
'\u{41f}\u{440}\u{43e}\u{434}\u{43e}\u{432}\u{436}\u{438}\u{442}\u{438}',['md.stop']='\u{421}\u{442}\u{43e}\u{43f}',[
'md.running']='\u{41f}\u{440}\u{430}\u{446}\u{44e}\u{454}',['md.paused']=
'\u{41d}\u{430} \u{43f}\u{430}\u{443}\u{437}\u{456}',['md.none']=
'\u{414}\u{43b}\u{44f} \u{446}\u{44c}\u{43e}\u{433}\u{43e} \u{43f}\u{43b}\u{435}\u{439}\u{441}\u{443} \u{43c}\u{43e}\u{434}\u{443}\u{43b}\u{456}\u{432} \u{43d}\u{435}\u{43c}\u{430}\u{454}'
,['md.preset_on']=
'\u{41d}\u{430}\u{431}\u{456}\u{440} \u{443}\u{432}\u{456}\u{43c}\u{43a}\u{43d}\u{435}\u{43d}\u{43e}: %s',[
'md.preset_off']='\u{41d}\u{430}\u{431}\u{456}\u{440} \u{432}\u{438}\u{43c}\u{43a}\u{43d}\u{435}\u{43d}\u{43e}: %s',[
'c.module']='\u{41c}\u{43e}\u{434}\u{443}\u{43b}\u{44c}',['d.module']=
'\u{412}\u{456}\u{434}\u{43a}\u{440}\u{438}\u{442}\u{438} \u{456}\u{433}\u{440}\u{43e}\u{432}\u{438}\u{439} \u{43c}\u{43e}\u{434}\u{443}\u{43b}\u{44c}: \u{434}\u{435}\u{441}\u{44f}\u{442}\u{43a}\u{438} \u{444}\u{443}\u{43d}\u{43a}\u{446}\u{456}\u{439}, \u{43d}\u{430}\u{431}\u{43e}\u{440}\u{438} \u{439} \u{441}\u{446}\u{435}\u{43d}\u{430}\u{440}\u{456}\u{439}.'
,['c.preset']='\u{41d}\u{430}\u{431}\u{456}\u{440}',['d.preset']=
'\u{423}\u{432}\u{456}\u{43c}\u{43a}\u{43d}\u{443}\u{442}\u{438} \u{430}\u{431}\u{43e} \u{432}\u{438}\u{43c}\u{43a}\u{43d}\u{443}\u{442}\u{438} \u{43d}\u{430}\u{431}\u{456}\u{440} \u{444}\u{443}\u{43d}\u{43a}\u{446}\u{456}\u{439} \u{43c}\u{43e}\u{434}\u{443}\u{43b}\u{44f}.'
,['arg.module']='\u{43d}\u{435}\u{43c}\u{430}\u{454} \u{43c}\u{43e}\u{434}\u{443}\u{43b}\u{44f} \u{ab}%s\u{bb}',[
'arg.preset']='\u{43d}\u{435}\u{43c}\u{430}\u{454} \u{43d}\u{430}\u{431}\u{43e}\u{440}\u{443} \u{ab}%s\u{bb}'},es={[
'md.search']='Buscar en el m\u{f3}dulo',['sp.modules']='M\u{f3}dulos',['md.presets']='Conjuntos',['md.save']=
'Guardar actual',['md.my_preset']='Mi conjunto %d',['md.saved']='Conjunto guardado',['md.all_off']='Apagar todo',[
'md.section_on']='Todo s\u{ed}',['md.section_off']='Todo no',['md.params']='Ajustes de la secci\u{f3}n',['md.found']=
'Encontrado: %d',['md.of']='%d de %d activos',['md.start']='Iniciar',['md.pause']='Pausa',['md.resume']='Seguir',[
'md.stop']='Parar',['md.running']='En marcha',['md.paused']='En pausa',['md.none']='No hay m\u{f3}dulos para este juego'
,['md.preset_on']='Conjunto activado: %s',['md.preset_off']='Conjunto desactivado: %s',['c.module']='M\u{f3}dulo',[
'd.module']='Abre un m\u{f3}dulo del juego: decenas de funciones, conjuntos y una rutina.',['c.preset']='Conjunto',[
'd.preset']='Activa o desactiva un conjunto de funciones de un m\u{f3}dulo.',['arg.module']=
'no hay m\u{f3}dulo \u{ab}%s\u{bb}',['arg.preset']='no hay conjunto \u{ab}%s\u{bb}'},pt={['md.search']=
'Buscar no m\u{f3}dulo',['sp.modules']='M\u{f3}dulos',['md.presets']='Conjuntos',['md.save']='Salvar atual',[
'md.my_preset']='Meu conjunto %d',['md.saved']='Conjunto salvo',['md.all_off']='Desligar tudo',['md.section_on']=
'Ligar todos',['md.section_off']='Desligar todos',['md.params']='Ajustes da se\u{e7}\u{e3}o',['md.found']=
'Encontrado: %d',['md.of']='%d de %d ligados',['md.start']='Iniciar',['md.pause']='Pausar',['md.resume']='Continuar',[
'md.stop']='Parar',['md.running']='Rodando',['md.paused']='Pausado',['md.none']='Nenhum m\u{f3}dulo para este jogo',[
'md.preset_on']='Conjunto ligado: %s',['md.preset_off']='Conjunto desligado: %s',['c.module']='M\u{f3}dulo',['d.module']
='Abre um m\u{f3}dulo do jogo: dezenas de fun\u{e7}\u{f5}es, conjuntos e uma rotina.',['c.preset']='Conjunto',[
'd.preset']='Liga ou desliga um conjunto de fun\u{e7}\u{f5}es de um m\u{f3}dulo.',['arg.module']=
'n\u{e3}o h\u{e1} m\u{f3}dulo \u{201c}%s\u{201d}',['arg.preset']='n\u{e3}o h\u{e1} conjunto \u{201c}%s\u{201d}'},de={[
'md.search']='Im Modul suchen',['sp.modules']='Module',['md.presets']='Sets',['md.save']='Aktuelles speichern',[
'md.my_preset']='Mein Set %d',['md.saved']='Set gespeichert',['md.all_off']='Alles aus',['md.section_on']='Alle an',[
'md.section_off']='Alle aus',['md.params']='Einstellungen des Bereichs',['md.found']='Gefunden: %d',['md.of']=
'%d von %d an',['md.start']='Start',['md.pause']='Pause',['md.resume']='Weiter',['md.stop']='Stopp',['md.running']=
'L\u{e4}uft',['md.paused']='Pausiert',['md.none']='Keine Module f\u{fc}r dieses Spiel',['md.preset_on']='Set an: %s',[
'md.preset_off']='Set aus: %s',['c.module']='Modul',['d.module']=
'\u{d6}ffnet ein Spielmodul: Dutzende Funktionen, Sets und eine Routine.',['c.preset']='Set',['d.preset']=
'Schaltet ein Set von Funktionen eines Moduls an oder aus.',['arg.module']='kein Modul \u{201e}%s\u{201c}',['arg.preset'
]='kein Set \u{201e}%s\u{201c}'}}return bundle end function __DARKLUA_BUNDLE_MODULES.Y()local v=__DARKLUA_BUNDLE_MODULES
.cache.Y if not v then v={c=__modImpl()}__DARKLUA_BUNDLE_MODULES.cache.Y=v end return v.c end end do local function 
__modImpl()local Types=__DARKLUA_BUNDLE_MODULES.c()local function lang(t)local out={}for k,v in t do out['m.sandbox.'..k
]=v end return out end local bundle={en=lang({title='Sandbox',desc=
[[A demo module that works in any place: local lighting and camera, your character, a waypoint tour.]],['s.light']=
'Lighting',['s.camera']='Camera',['s.body']='Character',['s.tour']='Tour',['f.brightness']='Brightness',['f.nofog']=
'No fog',['f.night']='Night',['f.tone']='Tone',['f.contrast']='Contrast',['f.noshadows']='No shadows',['f.fov']=
'Field of view',['f.zoom']='Zoom distance',['f.camclip']='Camera through walls',['f.fly']='Fly',['f.noclip']='Noclip',[
'f.speed']='Walk speed',['f.jump']='Jump power',['f.infjump']='Infinite jump',['f.antiafk']='Anti-AFK',['f.delay']=
'Delay, s',['f.loop']='Repeat',['f.fromNearest']='Start from nearest',['f.announce']='Toast at each point',['o.neutral']
='neutral',['o.warm']='warm',['o.cold']='cold',['o.mono']='mono',['p.night']='Night',['p.explore']='Explore',['p.photo']
='Photo',run='Waypoint tour',no_waypoints='No waypoints here yet: setwp <name>',at='Point %d/%d \u{b7} %s',done=
'Tour finished'}),ru=lang({title='\u{41f}\u{435}\u{441}\u{43e}\u{447}\u{43d}\u{438}\u{446}\u{430}',desc=
'\u{414}\u{435}\u{43c}\u{43e}-\u{43c}\u{43e}\u{434}\u{443}\u{43b}\u{44c} \u{434}\u{43b}\u{44f} \u{43b}\u{44e}\u{431}\u{43e}\u{433}\u{43e} \u{43f}\u{43b}\u{435}\u{439}\u{441}\u{430}: \u{43b}\u{43e}\u{43a}\u{430}\u{43b}\u{44c}\u{43d}\u{44b}\u{439} \u{441}\u{432}\u{435}\u{442} \u{438} \u{43a}\u{430}\u{43c}\u{435}\u{440}\u{430}, \u{432}\u{430}\u{448} \u{43f}\u{435}\u{440}\u{441}\u{43e}\u{43d}\u{430}\u{436}, \u{43e}\u{431}\u{445}\u{43e}\u{434} \u{442}\u{43e}\u{447}\u{435}\u{43a}.'
,['s.light']='\u{41e}\u{441}\u{432}\u{435}\u{449}\u{435}\u{43d}\u{438}\u{435}',['s.camera']=
'\u{41a}\u{430}\u{43c}\u{435}\u{440}\u{430}',['s.body']='\u{41f}\u{435}\u{440}\u{441}\u{43e}\u{43d}\u{430}\u{436}',[
's.tour']='\u{41e}\u{431}\u{445}\u{43e}\u{434}',['f.brightness']='\u{42f}\u{440}\u{43a}\u{43e}\u{441}\u{442}\u{44c}',[
'f.nofog']='\u{411}\u{435}\u{437} \u{442}\u{443}\u{43c}\u{430}\u{43d}\u{430}',['f.night']='\u{41d}\u{43e}\u{447}\u{44c}'
,['f.tone']='\u{422}\u{43e}\u{43d}',['f.contrast']='\u{41a}\u{43e}\u{43d}\u{442}\u{440}\u{430}\u{441}\u{442}',[
'f.noshadows']='\u{411}\u{435}\u{437} \u{442}\u{435}\u{43d}\u{435}\u{439}',['f.fov']=
'\u{41f}\u{43e}\u{43b}\u{435} \u{437}\u{440}\u{435}\u{43d}\u{438}\u{44f}',['f.zoom']=
'\u{41e}\u{442}\u{434}\u{430}\u{43b}\u{435}\u{43d}\u{438}\u{435}',['f.camclip']=
'\u{41a}\u{430}\u{43c}\u{435}\u{440}\u{430} \u{441}\u{43a}\u{432}\u{43e}\u{437}\u{44c} \u{441}\u{442}\u{435}\u{43d}\u{44b}'
,['f.fly']='\u{41f}\u{43e}\u{43b}\u{451}\u{442}',['f.noclip']=
'\u{421}\u{43a}\u{432}\u{43e}\u{437}\u{44c} \u{441}\u{442}\u{435}\u{43d}\u{44b}',['f.speed']=
'\u{421}\u{43a}\u{43e}\u{440}\u{43e}\u{441}\u{442}\u{44c}',['f.jump']=
'\u{421}\u{438}\u{43b}\u{430} \u{43f}\u{440}\u{44b}\u{436}\u{43a}\u{430}',['f.infjump']=
'\u{411}\u{435}\u{441}\u{43a}. \u{43f}\u{440}\u{44b}\u{436}\u{43e}\u{43a}',['f.antiafk']=
'\u{410}\u{43d}\u{442}\u{438}-\u{410}\u{424}\u{41a}',['f.delay']=
'\u{417}\u{430}\u{434}\u{435}\u{440}\u{436}\u{43a}\u{430}, \u{441}',['f.loop']=
'\u{41f}\u{43e}\u{432}\u{442}\u{43e}\u{440}\u{44f}\u{442}\u{44c}',['f.fromNearest']=
'\u{421} \u{431}\u{43b}\u{438}\u{436}\u{430}\u{439}\u{448}\u{435}\u{439}',['f.announce']=
'\u{422}\u{43e}\u{441}\u{442} \u{43d}\u{430} \u{442}\u{43e}\u{447}\u{43a}\u{435}',['o.neutral']=
'\u{43e}\u{431}\u{44b}\u{447}\u{43d}\u{44b}\u{439}',['o.warm']='\u{442}\u{451}\u{43f}\u{43b}\u{44b}\u{439}',['o.cold']=
'\u{445}\u{43e}\u{43b}\u{43e}\u{434}\u{43d}\u{44b}\u{439}',['o.mono']='\u{447}/\u{431}',['p.night']=
'\u{41d}\u{43e}\u{447}\u{44c}',['p.explore']='\u{420}\u{430}\u{437}\u{432}\u{435}\u{434}\u{43a}\u{430}',['p.photo']=
'\u{41a}\u{430}\u{434}\u{440}',run='\u{41e}\u{431}\u{445}\u{43e}\u{434} \u{442}\u{43e}\u{447}\u{435}\u{43a}',
no_waypoints=
'\u{417}\u{434}\u{435}\u{441}\u{44c} \u{43f}\u{43e}\u{43a}\u{430} \u{43d}\u{435}\u{442} \u{442}\u{43e}\u{447}\u{435}\u{43a}: setwp <\u{438}\u{43c}\u{44f}>'
,at='\u{422}\u{43e}\u{447}\u{43a}\u{430} %d/%d \u{b7} %s',done=
'\u{41e}\u{431}\u{445}\u{43e}\u{434} \u{437}\u{430}\u{43a}\u{43e}\u{43d}\u{447}\u{435}\u{43d}'}),uk=lang({title=
'\u{41f}\u{456}\u{441}\u{43e}\u{447}\u{43d}\u{438}\u{446}\u{44f}',desc=
'\u{414}\u{435}\u{43c}\u{43e}-\u{43c}\u{43e}\u{434}\u{443}\u{43b}\u{44c} \u{434}\u{43b}\u{44f} \u{431}\u{443}\u{434}\u{44c}-\u{44f}\u{43a}\u{43e}\u{433}\u{43e} \u{43f}\u{43b}\u{435}\u{439}\u{441}\u{443}: \u{43b}\u{43e}\u{43a}\u{430}\u{43b}\u{44c}\u{43d}\u{435} \u{441}\u{432}\u{456}\u{442}\u{43b}\u{43e} \u{439} \u{43a}\u{430}\u{43c}\u{435}\u{440}\u{430}, \u{432}\u{430}\u{448} \u{43f}\u{435}\u{440}\u{441}\u{43e}\u{43d}\u{430}\u{436}, \u{43e}\u{431}\u{445}\u{456}\u{434} \u{442}\u{43e}\u{447}\u{43e}\u{43a}.'
,['s.light']='\u{41e}\u{441}\u{432}\u{456}\u{442}\u{43b}\u{435}\u{43d}\u{43d}\u{44f}',['s.camera']=
'\u{41a}\u{430}\u{43c}\u{435}\u{440}\u{430}',['s.body']='\u{41f}\u{435}\u{440}\u{441}\u{43e}\u{43d}\u{430}\u{436}',[
's.tour']='\u{41e}\u{431}\u{445}\u{456}\u{434}',['f.brightness']=
'\u{42f}\u{441}\u{43a}\u{440}\u{430}\u{432}\u{456}\u{441}\u{442}\u{44c}',['f.nofog']=
'\u{411}\u{435}\u{437} \u{442}\u{443}\u{43c}\u{430}\u{43d}\u{443}',['f.night']='\u{41d}\u{456}\u{447}',['f.tone']=
'\u{422}\u{43e}\u{43d}',['f.contrast']='\u{41a}\u{43e}\u{43d}\u{442}\u{440}\u{430}\u{441}\u{442}',['f.noshadows']=
'\u{411}\u{435}\u{437} \u{442}\u{456}\u{43d}\u{435}\u{439}',['f.fov']=
'\u{41f}\u{43e}\u{43b}\u{435} \u{437}\u{43e}\u{440}\u{443}',['f.zoom']=
'\u{412}\u{456}\u{434}\u{434}\u{430}\u{43b}\u{435}\u{43d}\u{43d}\u{44f}',['f.camclip']=
'\u{41a}\u{430}\u{43c}\u{435}\u{440}\u{430} \u{43a}\u{440}\u{456}\u{437}\u{44c} \u{441}\u{442}\u{456}\u{43d}\u{438}',[
'f.fly']='\u{41f}\u{43e}\u{43b}\u{456}\u{442}',['f.noclip']=
'\u{41a}\u{440}\u{456}\u{437}\u{44c} \u{441}\u{442}\u{456}\u{43d}\u{438}',['f.speed']=
'\u{428}\u{432}\u{438}\u{434}\u{43a}\u{456}\u{441}\u{442}\u{44c}',['f.jump']=
'\u{421}\u{438}\u{43b}\u{430} \u{441}\u{442}\u{440}\u{438}\u{431}\u{43a}\u{430}',['f.infjump']=
'\u{41d}\u{435}\u{441}\u{43a}. \u{441}\u{442}\u{440}\u{438}\u{431}\u{43e}\u{43a}',['f.antiafk']=
'\u{410}\u{43d}\u{442}\u{438}-\u{410}\u{424}\u{41a}',['f.delay']=
'\u{417}\u{430}\u{442}\u{440}\u{438}\u{43c}\u{43a}\u{430}, \u{441}',['f.loop']=
'\u{41f}\u{43e}\u{432}\u{442}\u{43e}\u{440}\u{44e}\u{432}\u{430}\u{442}\u{438}',['f.fromNearest']=
'\u{417} \u{43d}\u{430}\u{439}\u{431}\u{43b}\u{438}\u{436}\u{447}\u{43e}\u{457}',['f.announce']=
'\u{422}\u{43e}\u{441}\u{442} \u{43d}\u{430} \u{442}\u{43e}\u{447}\u{446}\u{456}',['o.neutral']=
'\u{437}\u{432}\u{438}\u{447}\u{430}\u{439}\u{43d}\u{438}\u{439}',['o.warm']=
'\u{442}\u{435}\u{43f}\u{43b}\u{438}\u{439}',['o.cold']='\u{445}\u{43e}\u{43b}\u{43e}\u{434}\u{43d}\u{438}\u{439}',[
'o.mono']='\u{447}/\u{431}',['p.night']='\u{41d}\u{456}\u{447}',['p.explore']=
'\u{420}\u{43e}\u{437}\u{432}\u{456}\u{434}\u{43a}\u{430}',['p.photo']='\u{41a}\u{430}\u{434}\u{440}',run=
'\u{41e}\u{431}\u{445}\u{456}\u{434} \u{442}\u{43e}\u{447}\u{43e}\u{43a}',no_waypoints=
'\u{422}\u{443}\u{442} \u{43f}\u{43e}\u{43a}\u{438} \u{43d}\u{435}\u{43c}\u{430}\u{454} \u{442}\u{43e}\u{447}\u{43e}\u{43a}: setwp <\u{43d}\u{430}\u{437}\u{432}\u{430}>'
,at='\u{422}\u{43e}\u{447}\u{43a}\u{430} %d/%d \u{b7} %s',done=
'\u{41e}\u{431}\u{445}\u{456}\u{434} \u{437}\u{430}\u{432}\u{435}\u{440}\u{448}\u{435}\u{43d}\u{43e}'}),es=lang({title=
'Sandbox',desc=
'M\u{f3}dulo de demostraci\u{f3}n para cualquier juego: luz y c\u{e1}mara locales, tu personaje, recorrido de puntos.',[
's.light']='Iluminaci\u{f3}n',['s.camera']='C\u{e1}mara',['s.body']='Personaje',['s.tour']='Recorrido',['f.brightness']=
'Brillo',['f.nofog']='Sin niebla',['f.night']='Noche',['f.tone']='Tono',['f.contrast']='Contraste',['f.noshadows']=
'Sin sombras',['f.fov']='Campo de visi\u{f3}n',['f.zoom']='Distancia de zoom',['f.camclip']=
'C\u{e1}mara a trav\u{e9}s de paredes',['f.fly']='Volar',['f.noclip']='Atravesar paredes',['f.speed']='Velocidad',[
'f.jump']='Fuerza de salto',['f.infjump']='Salto infinito',['f.antiafk']='Anti-AFK',['f.delay']='Retraso, s',['f.loop']=
'Repetir',['f.fromNearest']='Desde el m\u{e1}s cercano',['f.announce']='Aviso en cada punto',['o.neutral']='neutro',[
'o.warm']='c\u{e1}lido',['o.cold']='fr\u{ed}o',['o.mono']='b/n',['p.night']='Noche',['p.explore']='Exploraci\u{f3}n',[
'p.photo']='Foto',run='Recorrido de puntos',no_waypoints='A\u{fa}n no hay puntos aqu\u{ed}: setwp <nombre>',at=
'Punto %d/%d \u{b7} %s',done='Recorrido terminado'}),pt=lang({title='Sandbox',desc=
'M\u{f3}dulo de demonstra\u{e7}\u{e3}o para qualquer jogo: luz e c\u{e2}mera locais, seu personagem, percurso de pontos.'
,['s.light']='Ilumina\u{e7}\u{e3}o',['s.camera']='C\u{e2}mera',['s.body']='Personagem',['s.tour']='Percurso',[
'f.brightness']='Brilho',['f.nofog']='Sem neblina',['f.night']='Noite',['f.tone']='Tom',['f.contrast']='Contraste',[
'f.noshadows']='Sem sombras',['f.fov']='Campo de vis\u{e3}o',['f.zoom']='Dist\u{e2}ncia do zoom',['f.camclip']=
'C\u{e2}mera atrav\u{e9}s de paredes',['f.fly']='Voar',['f.noclip']='Atravessar paredes',['f.speed']='Velocidade',[
'f.jump']='For\u{e7}a do pulo',['f.infjump']='Pulo infinito',['f.antiafk']='Anti-AFK',['f.delay']='Atraso, s',['f.loop']
='Repetir',['f.fromNearest']='Do mais pr\u{f3}ximo',['f.announce']='Aviso em cada ponto',['o.neutral']='neutro',[
'o.warm']='quente',['o.cold']='frio',['o.mono']='p/b',['p.night']='Noite',['p.explore']='Explora\u{e7}\u{e3}o',[
'p.photo']='Foto',run='Percurso de pontos',no_waypoints='Ainda n\u{e3}o h\u{e1} pontos aqui: setwp <nome>',at=
'Ponto %d/%d \u{b7} %s',done='Percurso conclu\u{ed}do'}),de=lang({title='Sandbox',desc=
'Demo-Modul f\u{fc}r jedes Spiel: lokales Licht und Kamera, dein Charakter, eine Wegpunkt-Tour.',['s.light']='Licht',[
's.camera']='Kamera',['s.body']='Charakter',['s.tour']='Tour',['f.brightness']='Helligkeit',['f.nofog']='Kein Nebel',[
'f.night']='Nacht',['f.tone']='Farbton',['f.contrast']='Kontrast',['f.noshadows']='Keine Schatten',['f.fov']='Sichtfeld'
,['f.zoom']='Zoomweite',['f.camclip']='Kamera durch W\u{e4}nde',['f.fly']='Fliegen',['f.noclip']='Durch W\u{e4}nde',[
'f.speed']='Laufgeschwindigkeit',['f.jump']='Sprungkraft',['f.infjump']='Endlos springen',['f.antiafk']='Anti-AFK',[
'f.delay']='Pause, s',['f.loop']='Wiederholen',['f.fromNearest']='Ab dem n\u{e4}chsten',['f.announce']=
'Hinweis je Punkt',['o.neutral']='neutral',['o.warm']='warm',['o.cold']='kalt',['o.mono']='s/w',['p.night']='Nacht',[
'p.explore']='Erkunden',['p.photo']='Foto',run='Wegpunkt-Tour',no_waypoints=
'Hier gibt es noch keine Wegpunkte: setwp <name>',at='Punkt %d/%d \u{b7} %s',done='Tour beendet'})}return bundle end
function __DARKLUA_BUNDLE_MODULES.Z()local v=__DARKLUA_BUNDLE_MODULES.cache.Z if not v then v={c=__modImpl()}
__DARKLUA_BUNDLE_MODULES.cache.Z=v end return v.c end end do local function __modImpl()local Types=
__DARKLUA_BUNDLE_MODULES.c()local spec={id='sandbox',badge='Demo',sections={'light','camera','body','tour'},runner=true,
features={{id='brightness',section='light',kind='number',min=0,max=6,step=0.1,default=2},{id='nofog',section='light',
kind='toggle'},{id='night',section='light',kind='toggle'},{id='tone',section='light',kind='choice',options={'neutral',
'warm','cold','mono'}},{id='contrast',section='light',kind='number',min=-1,max=1,step=0.05,default=0},{id='noshadows',
section='light',kind='toggle'},{id='fov',section='camera',kind='number',min=40,max=120,step=1,default=70},{id='zoom',
section='camera',kind='number',min=10,max=2000,step=10,default=400},{id='camclip',section='camera',kind='toggle'},{id=
'fly',section='body',kind='toggle',command='fly'},{id='noclip',section='body',kind='toggle',command='noclip'},{id=
'speed',section='body',kind='number',min=0,max=200,step=1,default=16,command='speed'},{id='jump',section='body',kind=
'number',min=0,max=300,step=1,default=50,command='jumppower'},{id='infjump',section='body',kind='toggle',command=
'infjump'},{id='antiafk',section='body',kind='toggle',command='antiafk'},{id='delay',section='tour',kind='number',min=
0.5,max=10,step=0.5,default=3},{id='loop',section='tour',kind='toggle'},{id='fromNearest',section='tour',kind='toggle'},
{id='announce',section='tour',kind='toggle'}},presets={{id='night',values={night=true,nofog=true,tone='cold',brightness=
1}},{id='explore',values={fly=true,noclip=true,speed=64,fov=90}},{id='photo',values={fov=50,zoom=800,camclip=true,
brightness=3,tone='warm'}}}}return spec end function __DARKLUA_BUNDLE_MODULES._()local v=__DARKLUA_BUNDLE_MODULES.cache.
_ if not v then v={c=__modImpl()}__DARKLUA_BUNDLE_MODULES.cache._=v end return v.c end end do local function __modImpl()
local Types=__DARKLUA_BUNDLE_MODULES.c()local Commands={}local SPEC_MODULES={__DARKLUA_BUNDLE_MODULES.P(),
__DARKLUA_BUNDLE_MODULES.Q(),__DARKLUA_BUNDLE_MODULES.R()}local STRING_MODULES={__DARKLUA_BUNDLE_MODULES.S(),
__DARKLUA_BUNDLE_MODULES.T(),__DARKLUA_BUNDLE_MODULES.U(),__DARKLUA_BUNDLE_MODULES.V(),__DARKLUA_BUNDLE_MODULES.W(),
__DARKLUA_BUNDLE_MODULES.X(),__DARKLUA_BUNDLE_MODULES.Y(),__DARKLUA_BUNDLE_MODULES.Z()}local specs={}for _,list in
SPEC_MODULES do for _,s in list do table.insert(specs,s)end end local GAME_MODULES={__DARKLUA_BUNDLE_MODULES._()}
Commands.specs=specs Commands.games=GAME_MODULES Commands.strings=STRING_MODULES Commands.VERSION='1.0.0'return Commands
end function __DARKLUA_BUNDLE_MODULES.aa()local v=__DARKLUA_BUNDLE_MODULES.cache.aa if not v then v={c=__modImpl()}
__DARKLUA_BUNDLE_MODULES.cache.aa=v end return v.c end end do local function __modImpl()local CtxTypes=
__DARKLUA_BUNDLE_MODULES.m()local Format=__DARKLUA_BUNDLE_MODULES.i()return function(hooks)local handlers={help={run=
function(ctx,args)local name=args[1]if name then local spec=hooks.spec(name)ctx.toast('info',ctx.t('help.one',Format.
signature(spec),ctx.t('d.'..spec.name)))ctx.openView('list')else ctx.toast('info',ctx.t('help.count',hooks.count()))ctx.
openView('all')end end},bind={run=function(ctx,args)local key=args[1]local line=args[2]ctx.store.data.binds[key.Name]=
line ctx.store:Save('binds')ctx.toast('ok',ctx.t('toast.bound',key.Name,line))end},unbind={run=function(ctx,args)local
key=args[1]local binds=ctx.store.data.binds if binds[key.Name]==nil then ctx.toast('info',ctx.t('hub.no_bind',key.Name))
return end binds[key.Name]=nil ctx.store:Save('binds')ctx.toast('ok',ctx.t('toast.unbound',key.Name))end},binds={run=
function(ctx)ctx.openView('settings')end},togglekey={run=function(ctx,args)local key=args[1]ctx.store.data.toggleKey=if
key then key.Name else'RightShift'ctx.store:Save('toggleKey')ctx.toast('ok',ctx.t('hub.togglekey',ctx.store.data.
toggleKey))end},lang={run=function(_ctx,args)hooks.setLang(args[1])end},enable={run=function(ctx,args)hooks.setDisabled(
args[1],false)ctx.toast('ok',ctx.t('toast.cmd_enabled',args[1]))end},disable={run=function(ctx,args)hooks.setDisabled(
args[1],true)ctx.toast('info',ctx.t('toast.cmd_disabled',args[1]))end},settings={run=function(ctx)ctx.openView(
'settings')end},log={run=function(ctx)ctx.openView('log')end},module={run=function(ctx,args)ctx.openModule((args[1])or''
)end},preset={run=function(ctx,args)local key=args[1]local on,title=hooks.togglePreset(key)if on==nil then ctx.fail(ctx.
t('arg.preset',key))end ctx.toast('ok',ctx.t(if on then'md.preset_on'else'md.preset_off',title))end},unload={run=
function()task.defer(hooks.unload)end}}return{handlers=handlers}end end function __DARKLUA_BUNDLE_MODULES.ab()local v=
__DARKLUA_BUNDLE_MODULES.cache.ab if not v then v={c=__modImpl()}__DARKLUA_BUNDLE_MODULES.cache.ab=v end return v.c end
end do local function __modImpl()local CtxTypes=__DARKLUA_BUNDLE_MODULES.m()local Body={}function Body.need(ctx)local
char=ctx.character()local hum=ctx.humanoid()local root=ctx.root()if not(char and hum and root)or hum.Health<=0 then ctx.
fail(ctx.t('chr.no_character'))end return char,hum,root end return Body end function __DARKLUA_BUNDLE_MODULES.ac()local
v=__DARKLUA_BUNDLE_MODULES.cache.ac if not v then v={c=__modImpl()}__DARKLUA_BUNDLE_MODULES.cache.ac=v end return v.c
end end do local function __modImpl()local UserInputService=game:GetService('UserInputService')local Body=
__DARKLUA_BUNDLE_MODULES.ac()local CtxTypes=__DARKLUA_BUNDLE_MODULES.m()local Janitor=__DARKLUA_BUNDLE_MODULES.j()local
FLY_DEFAULT=50 local JUMP_HOLD=0.25 local K=Enum.KeyCode local Movement={}function Movement.handlers()local flySpeed=
FLY_DEFAULT local function fly(ctx,args,jan)local _,hum,root=Body.need(ctx)local fixed=args[1]local att=Instance.new(
'Attachment')att.Name='TZAR_FlyAttachment'att.Parent=root jan:Add(att)local lv=Instance.new('LinearVelocity')lv.Name=
'TZAR_Fly'lv.Attachment0=att lv.RelativeTo=Enum.ActuatorRelativeTo.World lv.VelocityConstraintMode=Enum.
VelocityConstraintMode.Vector lv.MaxForce=math.huge lv.VectorVelocity=Vector3.zero lv.Parent=root jan:Add(lv)local ao=
Instance.new('AlignOrientation')ao.Name='TZAR_FlyAlign'ao.Mode=Enum.OrientationAlignmentMode.OneAttachment ao.
Attachment0=att ao.MaxTorque=math.huge ao.Responsiveness=60 ao.CFrame=root.CFrame.Rotation ao.Parent=root jan:Add(ao)jan
:Set(hum,'PlatformStand',true)local lastJump=0 jan:Connect(UserInputService.JumpRequest,function()lastJump=os.clock()end
)local remove=ctx.scheduler:Add('render',function()local cam=workspace.CurrentCamera if not cam or root.Parent==nil then
return end local cf=cam.CFrame local look,right=cf.LookVector,cf.RightVector local fwd,side,up=0,0,0 if not
UserInputService:GetFocusedTextBox()then if UserInputService:IsKeyDown(K.W)then fwd+=1 end if UserInputService:
IsKeyDown(K.S)then fwd-=1 end if UserInputService:IsKeyDown(K.D)then side+=1 end if UserInputService:IsKeyDown(K.A)then
side-=1 end if UserInputService:IsKeyDown(K.Space)or UserInputService:IsKeyDown(K.E)then up+=1 end if UserInputService:
IsKeyDown(K.LeftControl)or UserInputService:IsKeyDown(K.Q)then up-=1 end end if fwd==0 and side==0 then local md=hum.
MoveDirection if md.Magnitude>0.05 then local flatLook=Vector3.new(look.X,0,look.Z)local flatRight=Vector3.new(right.X,0
,right.Z)if flatLook.Magnitude>0.01 then fwd=md:Dot(flatLook.Unit)side=md:Dot(flatRight.Unit)end end end if up==0 and os
.clock()-lastJump<JUMP_HOLD then up=1 end local dir=look*fwd+right*side+Vector3.yAxis*up if dir.Magnitude>1 then dir=dir
.Unit end lv.VectorVelocity=dir*(fixed or flySpeed)local flat=Vector3.new(look.X,0,look.Z)if flat.Magnitude>0.01 then ao
.PrimaryAxis=flat.Unit:Cross(Vector3.yAxis)ao.SecondaryAxis=Vector3.yAxis end end,function(msg)ctx.log:Error('fly: '..
msg)end)jan:Defer(function()if root.Parent then root.AssemblyLinearVelocity=Vector3.zero end end)jan:Defer(remove)end
local function noclip(ctx,_args,jan)local char=Body.need(ctx)local parts={}local original={}local function track(d)if d:
IsA('BasePart')and original[d]==nil then original[d]=d.CanCollide table.insert(parts,d)end end for _,d in char:
GetDescendants()do track(d)end jan:Connect(char.DescendantAdded,track)jan:Connect(char.DescendantRemoving,function(d)if
d:IsA('BasePart')then local i=table.find(parts,d)if i then table.remove(parts,i)end original[d]=nil end end)local remove
=ctx.scheduler:Add('stepped',function()for i=1,#parts do local p=parts[i]if p.CanCollide then p.CanCollide=false end end
end)jan:Defer(function()for p,was in original do if p.Parent then p.CanCollide=was end end end)jan:Defer(remove)end
local function hold(jan,hum,prop,value)jan:Set(hum,prop,value)jan:Connect(hum:GetPropertyChangedSignal(prop),function()
if(hum)[prop]~=value then(hum)[prop]=value end end)end return{fly={enable=fly},flyspeed={enable=function(_ctx,args,jan)
flySpeed=args[1]jan:Defer(function()flySpeed=FLY_DEFAULT end)end,current=function()return flySpeed end},noclip={enable=
noclip},speed={enable=function(ctx,args,jan)local _,hum=Body.need(ctx)hold(jan,hum,'WalkSpeed',args[1])end,current=
function(ctx)local hum=ctx.humanoid()return hum and hum.WalkSpeed end},jumppower={enable=function(ctx,args,jan)local _,
hum=Body.need(ctx)jan:Set(hum,'UseJumpPower',true)hold(jan,hum,'JumpPower',args[1])end,current=function(ctx)local hum=
ctx.humanoid()return hum and hum.UseJumpPower and hum.JumpPower or nil end},infjump={enable=function(ctx,_args,jan)local
last=0 jan:Connect(UserInputService.JumpRequest,function()local now=os.clock()if now-last<0.12 then return end last=now
local hum=ctx.humanoid()if hum and hum.Health>0 then hum:ChangeState(Enum.HumanoidStateType.Jumping)end end)end}}end
return Movement end function __DARKLUA_BUNDLE_MODULES.ad()local v=__DARKLUA_BUNDLE_MODULES.cache.ad if not v then v={c=
__modImpl()}__DARKLUA_BUNDLE_MODULES.cache.ad=v end return v.c end end do local function __modImpl()local HttpService=
game:GetService('HttpService')local Body=__DARKLUA_BUNDLE_MODULES.ac()local CtxTypes=__DARKLUA_BUNDLE_MODULES.m()local
Env=__DARKLUA_BUNDLE_MODULES.a()local PATH='TZAR/admin/waypoints.json'local Waypoints={}function Waypoints.module()local
all=nil local function place()if not all then local body=Env.readFile(PATH)local data=body and Env.json(body)all=if
type(data)=='table'then data else{}end local key=tostring(game.PlaceId)local t=all t[key]=t[key]or{}return t[key]end
local function save()local ok,body=pcall(HttpService.JSONEncode,HttpService,all or{})if ok then Env.writeFile(PATH,body)
end end local function names()local out={}for name in place()do table.insert(out,name)end table.sort(out)return out end
local handlers={setwp={run=function(ctx,args)local _,_,root=Body.need(ctx)local name=string.gsub(args[1],'^%s*(.-)%s*$',
'%1')local p=root.Position local _,yaw=root.CFrame:ToOrientation()place()[name]={x=p.X,y=p.Y,z=p.Z,yaw=yaw}save()ctx.
toast('ok',ctx.t('chr.wp_saved',name))end},wp={run=function(ctx,args)local _,_,root=Body.need(ctx)local name=args[1]
local pt=place()[name]if not pt then ctx.fail(ctx.t('arg.waypoint',name))end root.AssemblyLinearVelocity=Vector3.zero
root.CFrame=CFrame.new(pt.x,pt.y,pt.z)*CFrame.Angles(0,pt.yaw or 0,0)ctx.toast('ok',ctx.t('chr.wp_moved',name))end},
delwp={run=function(ctx,args)local name=args[1]place()[name]=nil save()ctx.toast('ok',ctx.t('chr.wp_deleted',name))end},
waypoints={run=function(ctx)local list=names()if#list==0 then ctx.toast('info',ctx.t('chr.wp_none'))else ctx.toast(
'info',ctx.t('chr.wp_list',table.concat(list,', ')))end end}}return handlers,function()return names()end end return
Waypoints end function __DARKLUA_BUNDLE_MODULES.ae()local v=__DARKLUA_BUNDLE_MODULES.cache.ae if not v then v={c=
__modImpl()}__DARKLUA_BUNDLE_MODULES.cache.ae=v end return v.c end end do local function __modImpl()local Players=game:
GetService('Players')local VirtualUser=game:GetService('VirtualUser')local Body=__DARKLUA_BUNDLE_MODULES.ac()local
CtxTypes=__DARKLUA_BUNDLE_MODULES.m()local Janitor=__DARKLUA_BUNDLE_MODULES.j()local Movement=__DARKLUA_BUNDLE_MODULES.
ad()local Waypoints=__DARKLUA_BUNDLE_MODULES.ae()local RESPAWN_TIMEOUT=15 local function respawn(ctx)local hum=ctx.
humanoid()if not hum then ctx.fail(ctx.t('chr.no_character'))end(hum).Health=0 end return function()local handlers=
Movement.handlers()local wpHandlers,wpNames=Waypoints.module()for k,v in wpHandlers do handlers[k]=v end handlers.sit={
run=function(ctx)local _,hum=Body.need(ctx)hum.Sit=true end}handlers.lay={run=function(ctx)local _,hum,root=Body.need(
ctx)hum.Sit=true task.wait(0.15)if root.Parent then root.CFrame=root.CFrame*CFrame.Angles(math.pi/2,0,0)end end}handlers
.antiafk={enable=function(_ctx,_args,jan)jan:Connect(Players.LocalPlayer.Idled,function()VirtualUser:CaptureController()
VirtualUser:ClickButton2(Vector2.zero)end)end}handlers.respawn={run=function(ctx)respawn(ctx)ctx.toast('info',ctx.t(
'chr.respawned'))end}handlers.refresh={run=function(ctx)local _,_,root=Body.need(ctx)local at=root.CFrame local lp=
Players.LocalPlayer local done=false local newChar=nil local conn=lp.CharacterAdded:Connect(function(c)newChar=c done=
true end)respawn(ctx)local start=os.clock()while not done and os.clock()-start<RESPAWN_TIMEOUT do task.wait(0.1)end conn
:Disconnect()local c=newChar if not c then ctx.fail(ctx.t('chr.no_character'))end local r=(c):WaitForChild(
'HumanoidRootPart',10)if r and r:IsA('BasePart')then task.wait(0.1)r.CFrame=at end ctx.toast('info',ctx.t(
'chr.respawned'))end}return{handlers=handlers,lists={waypoint=wpNames}}end end function __DARKLUA_BUNDLE_MODULES.af()
local v=__DARKLUA_BUNDLE_MODULES.cache.af if not v then v={c=__modImpl()}__DARKLUA_BUNDLE_MODULES.cache.af=v end return
v.c end end do local function __modImpl()local HttpService=game:GetService('HttpService')local Env=
__DARKLUA_BUNDLE_MODULES.a()local PATH='TZAR/admin/avatar.json'local OLD_OUTFITS='AvatarChanger/outfits.json'local
OLD_CONFIG='AvatarChanger/config.json'local VERSION=1 local DESC_NUMBERS={'Head','Torso','LeftArm','RightArm','LeftLeg',
'RightLeg','Face','Shirt','Pants','GraphicTShirt','BodyTypeScale','DepthScale','HeadScale','HeightScale',
'ProportionScale','WidthScale','ClimbAnimation','FallAnimation','IdleAnimation','JumpAnimation','MoodAnimation',
'RunAnimation','SwimAnimation','WalkAnimation'}local DESC_COLORS={'HeadColor','TorsoColor','LeftArmColor',
'RightArmColor','LeftLegColor','RightLegColor'}local Data={}local function readJson(path)local body=Env.readFile(path)
return if body then Env.json(body)else nil end local function oldEmotes(config)local out={}if type(config)~='table'then
return out end local function add(e)if type(e)=='table'and tonumber(e.id)then table.insert(out,{id=(tonumber(e.id)),name
=tostring(e.name or e.id)})end end if type(config.emoteList)=='table'then for _,e in config.emoteList do add(e)end
elseif type(config.emoteSlots)=='table'then for i=1,8 do add(config.emoteSlots[tostring(i)])end end return out end
function Data.load()local raw=readJson(PATH)local d={version=VERSION,outfits={},emotes={},outfitEmotes=true,imported=
false}if type(raw)=='table'then d.outfits=if type(raw.outfits)=='table'then raw.outfits else{}d.emotes=if type(raw.
emotes)=='table'then raw.emotes else{}d.outfitEmotes=raw.outfitEmotes~=false d.imported=raw.imported==true end local
imported=0 if not d.imported then local old=readJson(OLD_OUTFITS)if type(old)=='table'and type(old.list)=='table'then
for _,o in old.list do if type(o)=='table'and type(o.data)=='table'then table.insert(d.outfits,{id=tostring(o.id or
HttpService:GenerateGUID(false)),name=tostring(o.name or'Outfit'),data=o.data})imported+=1 end end end local config=
readJson(OLD_CONFIG)for _,e in oldEmotes(config)do table.insert(d.emotes,e)imported+=1 end if type(config)=='table'and
config.useOutfitEmotes==false then d.outfitEmotes=false end d.imported=true Data.save(d)end return d,imported end
function Data.save(d)local ok,body=pcall(HttpService.JSONEncode,HttpService,d)if ok then Env.writeFile(PATH,body)end end
function Data.find(d,name)local lower=string.lower(name)for _,o in d.outfits do if string.lower(o.name)==lower or o.id==
name then return o end end return nil end function Data.unique(d,base)if not Data.find(d,base)then return base end local
n=2 while Data.find(d,string.format('%s (%d)',base,n))do n+=1 end return string.format('%s (%d)',base,n)end local 
function numStr(n)if n==math.floor(n)then return string.format('%d',n)end return string.format('%.17g',n)end local 
function v3(v)return if v then{v.X,v.Y,v.Z}else nil end function Data.serialize(desc)local dd=desc local t={numbers={},
colors={},accessories={}}for _,f in DESC_NUMBERS do t.numbers[f]=numStr(dd[f])end for _,f in DESC_COLORS do t.colors[f]=
(dd[f]):ToHex()end for _,a in desc:GetAccessories(true)do local acc=a table.insert(t.accessories,{AssetId=numStr(acc.
AssetId),AccessoryType=acc.AccessoryType.Name,IsLayered=acc.IsLayered,Order=acc.Order,Puffiness=acc.Puffiness,Position=
v3(acc.Position),Rotation=v3(acc.Rotation),Scale=v3(acc.Scale)})end local okE,emotes=pcall(function()return desc:
GetEmotes()end)local okQ,equipped=pcall(function()return desc:GetEquippedEmotes()end)if okE and okQ and type(equipped)==
'table'and#equipped>0 then t.emotes,t.equippedEmotes={},equipped for name,ids in emotes do t.emotes[name]={}for _,id in
ids do table.insert(t.emotes[name],numStr(id))end end end return t end local function vec(t)if type(t)=='table'and#t==3
then return Vector3.new(tonumber(t[1])or 0,tonumber(t[2])or 0,tonumber(t[3])or 0)end return nil end function Data.
deserialize(t)local desc=Instance.new('HumanoidDescription')local dd=desc for f,v in(if type(t.numbers)=='table'then t.
numbers else{})do pcall(function()dd[f]=tonumber(v)or 0 end)end for f,hex in(if type(t.colors)=='table'then t.colors
else{})do pcall(function()dd[f]=Color3.fromHex(hex)end)end local list={}for _,a in(if type(t.accessories)=='table'then t
.accessories else{})do local okT,accType=pcall(function()return(Enum.AccessoryType)[a.AccessoryType]end)table.insert(
list,{AssetId=tonumber(a.AssetId)or 0,AccessoryType=if okT and accType then accType else Enum.AccessoryType.Unknown,
IsLayered=a.IsLayered==true,Order=a.Order,Puffiness=a.Puffiness,Position=vec(a.Position),Rotation=vec(a.Rotation),Scale=
vec(a.Scale)})end if not pcall(desc.SetAccessories,desc,list,true)then for _,item in list do item.Position,item.Rotation
,item.Scale=nil,nil,nil end pcall(desc.SetAccessories,desc,list,true)end if type(t.emotes)=='table'and type(t.
equippedEmotes)=='table'then local emotes={}for name,ids in t.emotes do emotes[name]={}for _,id in ids do table.insert(
emotes[name],tonumber(id))end end pcall(desc.SetEmotes,desc,emotes)pcall(desc.SetEquippedEmotes,desc,t.equippedEmotes)
end return desc end return Data end function __DARKLUA_BUNDLE_MODULES.ag()local v=__DARKLUA_BUNDLE_MODULES.cache.ag if
not v then v={c=__modImpl()}__DARKLUA_BUNDLE_MODULES.cache.ag=v end return v.c end end do local function __modImpl()
local MarketplaceService=game:GetService('MarketplaceService')local StarterPlayer=game:GetService('StarterPlayer')local
Env=__DARKLUA_BUNDLE_MODULES.a()local Rules={}local ASSET_FIELD={[2]='GraphicTShirt',[11]='Shirt',[12]='Pants',[17]=
'Head',[18]='Face',[27]='Torso',[28]='RightArm',[29]='LeftArm',[30]='LeftLeg',[31]='RightLeg',[78]='MoodAnimation',[79]=
'Head'}Rules.ASSET_FIELD=ASSET_FIELD local ANIM_FIELDS={'ClimbAnimation','FallAnimation','IdleAnimation','JumpAnimation'
,'MoodAnimation','RunAnimation','SwimAnimation','WalkAnimation'}local BODY_FIELDS={'Head','Torso','LeftArm','RightArm',
'LeftLeg','RightLeg'}local cache=nil function Rules.call(obj,name,...)local args=table.pack(...)local hasAsync,async=
pcall(function()return obj[name..'Async']end)local fn=if hasAsync and async then async else nil if not fn then local
hasOld,old=pcall(function()return obj[name]end)fn=if hasOld then old else nil end if not fn then return false,'no '..
name end return pcall(function()return fn(obj,table.unpack(args,1,args.n))end)end function Rules.productInfo(id)local ok
,info=Rules.call(MarketplaceService,'GetProductInfo',id)return if ok and type(info)=='table'then info else nil end local 
function httpJson(url)local res=Env.http(url)if not res or not res.ok then return nil end return Env.json(res.body)end
local function prop(inst,name)if not inst then return nil end local ok,v=pcall(function()return(inst)[name]end)return if
ok then v else nil end local function is(v,name)return typeof(v)=='EnumItem'and(v).Name==name end local function num(v)
local n=tonumber(v)return if n and n>0 then n else 0 end local function load()local c=cache if c then return c end local
d={legacy=httpJson('https://avatar.roblox.com/v1/game-start-info?universeId='..tostring(game.GameId))}local ok,settings=
pcall(function()return(game):GetService('AvatarSettings')end)local root=if ok and settings then settings:
FindFirstChildOfClass('AvatarRules')else nil if root then d.body=root:FindFirstChildOfClass('AvatarBodyRules')d.acc=root
:FindFirstChildOfClass('AvatarAccessoryRules')d.cloth=root:FindFirstChildOfClass('AvatarClothingRules')d.anim=root:
FindFirstChildOfClass('AvatarAnimationRules')end cache=d return d end local function setAccessory(desc,typeName,assetId,
layered)pcall(function()local accType=(Enum.AccessoryType)[typeName]local out={}for _,a in desc:GetAccessories(true)do
if a.AccessoryType~=accType then table.insert(out,a)end end table.insert(out,{AssetId=assetId,AccessoryType=accType,
IsLayered=layered,Order=if layered then#out+1 else nil})desc:SetAccessories(out,true)end)end local function clampField(
desc,field,lo,hi,notes)local a,b=tonumber(lo),tonumber(hi)if not a or not b or(a==0 and b==0)then return end local d=
desc local v=d[field]local c=math.clamp(v,math.min(a,b),math.max(a,b))if math.abs(c-v)>1e-4 then d[field]=c table.
insert(notes,string.format('%s %.2f\u{2192}%.2f',field,v,c))end end local function clampRange(desc,field,range,notes)if
typeof(range)=='NumberRange'then clampField(desc,field,range.Min,range.Max,notes)end end local function applyBundle(desc
,bundleId,keepHead,notes)local data=httpJson('https://catalog.roblox.com/v1/bundles/'..bundleId..'/details')if type(data
)~='table'or type(data.items)~='table'then return end for _,it in data.items do if it.type=='Asset'then local info=Rules
.productInfo(it.id)local field=info and ASSET_FIELD[info.AssetTypeId]if field and not(keepHead and field=='Head')then(
desc)[field]=it.id end end end table.insert(notes,'bundle '..bundleId)end function Rules.apply(desc,notes)local r=load()
local d=desc local post={clips={},scale=false}if StarterPlayer.LoadCharacterAppearance==false then table.insert(notes,
'game hides avatars')end local legacy=r.legacy if type(legacy)=='table'then local mn=legacy.universeAvatarMinScales or{}
local mx=legacy.universeAvatarMaxScales or{}local map={height='HeightScale',width='WidthScale',head='HeadScale',depth=
'DepthScale',proportion='ProportionScale',bodyType='BodyTypeScale'}for key,field in map do clampField(desc,field,mn[key]
,mx[key],notes)end for _,o in legacy.universeAvatarAssetOverrides or{}do local field=ASSET_FIELD[o.assetTypeID]if field
and not o.isPlayerChoice and num(o.assetID)~=0 then d[field]=o.assetID table.insert(notes,field..'='..tostring(o.assetID
))end end if tostring(legacy.allowCustomAnimations)=='False'then for _,f in ANIM_FIELDS do d[f]=0 end table.insert(notes
,'standard animations')end end local b=r.body if b then local mode=prop(b,'AppearanceMode')if is(mode,'CustomParts')then
for _,part in{'Head','Torso','LeftArm','RightArm','LeftLeg','RightLeg','Face'}do local id=num(prop(b,'Custom'..part..
'Id'))if prop(b,'Custom'..part..'Enabled')and id~=0 then d[part]=id table.insert(notes,part..'='..id)end end if prop(b,
'CustomMoodEnabled')and num(prop(b,'CustomMoodId'))~=0 then d.MoodAnimation=num(prop(b,'CustomMoodId'))end if prop(b,
'CustomEyebrowEnabled')and num(prop(b,'CustomEyebrowId'))~=0 then setAccessory(desc,'Eyebrow',num(prop(b,
'CustomEyebrowId')),false)end if prop(b,'CustomEyelashEnabled')and num(prop(b,'CustomEyelashId'))~=0 then setAccessory(
desc,'Eyelash',num(prop(b,'CustomEyelashId')),false)end elseif is(mode,'CustomBody')then local bundle=num(prop(b,
'CustomBodyBundleId'))if is(prop(b,'CustomBodyType'),'BundleId')and bundle~=0 then applyBundle(desc,bundle,prop(b,
'KeepPlayerHead')==true,notes)end end for _,part in BODY_FIELDS do local v=num(prop(b,part..'Override'))if v~=0 then d[
part]=v table.insert(notes,part..'='..v)end end if is(prop(b,'ScaleMode'),'CustomScale')then clampRange(desc,
'HeightScale',prop(b,'CustomHeightScale'),notes)clampRange(desc,'WidthScale',prop(b,'CustomWidthScale'),notes)
clampRange(desc,'HeadScale',prop(b,'CustomHeadScale'),notes)clampRange(desc,'BodyTypeScale',prop(b,'CustomBodyTypeScale'
),notes)clampRange(desc,'ProportionScale',prop(b,'CustomProportionsScale'),notes)end if is(prop(b,'BuildMode'),
'CustomBuild')then clampRange(desc,'HeightScale',prop(b,'CustomBuildHeight'),notes)clampRange(desc,'WidthScale',prop(b,
'CustomBuildWidth'),notes)clampRange(desc,'HeadScale',prop(b,'CustomBuildHead'),notes)clampRange(desc,'BodyTypeScale',
prop(b,'CustomBuildBodyType'),notes)clampRange(desc,'ProportionScale',prop(b,'CustomBuildProportions'),notes)end end
local a=r.acc if a then local custom=is(prop(a,'CustomAccessoryMode'),'CustomAccessories')local slots={Back='Back',Face=
'Face',Front='Front',Hair='Hair',Head='Hat',Neck='Neck',Shoulder='Shoulder',Waist='Waist'}for slot,accType in slots do
local id=0 if custom and prop(a,'Custom'..slot..'AccessoryEnabled')then id=num(prop(a,'Custom'..slot..'AccessoryId'))end
if id==0 then id=num(prop(a,slot..'AccessoryOverride'))end if id~=0 then setAccessory(desc,accType,id,false)table.
insert(notes,accType..'='..id)end end local method=prop(a,'LimitMethod')if is(prop(a,'AccessoryMode'),'CustomLimit')and(
is(method,'Scale')or is(method,'Remove'))then local bounds=prop(a,'LimitBounds')post.accLimit=if typeof(bounds)==
'Vector3'then bounds else nil post.scale=is(method,'Scale')end end local c=r.cloth if c then local custom=is(prop(c,
'CustomClothingMode'),'CustomClothing')local function pick(key)local id=0 if custom and prop(c,'Custom'..key..
'AccessoryEnabled')then id=num(prop(c,'Custom'..key..'AccessoryId'))end if id==0 then id=num(prop(c,key..
'AccessoryOverride'))end return id end local classic={ClassicShirts='Shirt',ClassicPants='Pants',ClassicTShirts=
'GraphicTShirt'}for key,field in classic do local id=pick(key)if id~=0 then d[field]=id table.insert(notes,field..'='..
id)end end local layered={Jacket='Jacket',Shirt='Shirt',Sweater='Sweater',TShirt='TShirt',Pants='Pants',Shorts='Shorts',
DressSkirt='DressSkirt',LeftShoes='LeftShoe',RightShoes='RightShoe'}for key,accType in layered do local id=pick(key)if
id~=0 then setAccessory(desc,accType,id,true)table.insert(notes,accType..'='..id)end end if is(prop(c,'ClothingMode'),
'CustomLimit')then local bounds=prop(c,'LimitBounds')post.clothLimit=if typeof(bounds)=='Vector3'then bounds else nil
end end local an=r.anim if an then local packs=prop(an,'AnimationPacksMode')if typeof(packs)=='EnumItem'and not is(packs
,'PlayerChoice')then for _,f in ANIM_FIELDS do d[f]=0 end table.insert(notes,'standard animations')end local customClips
=is(prop(an,'AnimationClipsMode'),'CustomClips')local clipSlots={Climb='climb',Fall='fall',Idle='idle',Jump='jump',Run=
'run',Swim='swim',SwimIdle='swimidle',Walk='walk'}for key,slot in clipSlots do local id=0 if customClips and prop(an,
'Custom'..key..'AnimationEnabled')then id=num(prop(an,'Custom'..key..'AnimationId'))end if id==0 then id=num(prop(an,key
..'AnimationOverride'))end if id~=0 then post.clips[slot]=id end end local mood=num(prop(an,'MoodAnimationOverride'))if
mood~=0 then d.MoodAnimation=mood end end return post end local function scaleAccessory(h,f)h.Size*=f local m=h:
FindFirstChildOfClass('SpecialMesh')if m then m.Scale*=f end for _,x in h:GetChildren()do if x:IsA('Attachment')then x.
Position*=f end end end function Rules.limit(model,post,notes)for _,acc in model:GetChildren()do local h=if acc:IsA(
'Accoutrement')then acc:FindFirstChild('Handle')else nil if h and h:IsA('BasePart')then local layered=h:
FindFirstChildOfClass('WrapLayer')~=nil local bounds=if layered then post.clothLimit else post.accLimit if bounds and
bounds.Magnitude>0 then local f=1 for _,ax in{'X','Y','Z'}do local lim=(bounds)[ax]local size=(h.Size)[ax]if lim>0 and
size>lim then f=math.min(f,lim/size)end end if f<1 then if not layered and post.scale then scaleAccessory(h,f)table.
insert(notes,string.format('%s \u{d7}%.2f',acc.Name,f))else table.insert(notes,acc.Name..' removed')acc:Destroy()end end
end end end end return Rules end function __DARKLUA_BUNDLE_MODULES.ah()local v=__DARKLUA_BUNDLE_MODULES.cache.ah if not
v then v={c=__modImpl()}__DARKLUA_BUNDLE_MODULES.cache.ah=v end return v.c end end do local function __modImpl()local
HttpService=game:GetService('HttpService')local Players=game:GetService('Players')local Env=__DARKLUA_BUNDLE_MODULES.a()
local Rules=__DARKLUA_BUNDLE_MODULES.ah()local CACHE='TZAR/admin/emote_anims.json'local OLD_CACHE=
'AvatarChanger/emote_anims.json'local EMOTE_ASSET_TYPE=61 local SLOTS=8 local Emotes={}local LBASE={3,4,5,6,7,8,9,10,11,
13,15,17,19,23,27,31,35,43,51,59,67,83,99,115,131,163,195,227,258}local LEXT={0,0,0,0,0,0,0,0,1,1,1,1,2,2,2,2,3,3,3,3,4,
4,4,4,5,5,5,5,0}local DBASE={1,2,3,4,5,7,9,13,17,25,33,49,65,97,129,193,257,385,513,769,1025,1537,2049,3073,4097,6145,
8193,12289,16385,24577}local DEXT={0,0,0,0,1,1,2,2,3,3,4,4,5,5,6,6,7,7,8,8,9,9,10,10,11,11,12,12,13,13}local ORDER={16,
17,18,0,8,7,9,6,10,5,11,4,12,3,13,2,14,1,15}local function huff(lengths,n,from)local count={}local offs={}local sym={}
for i=0,15 do count[i]=0 end for i=0,n-1 do local l=lengths[from+i]or 0 count[l]+=1 end count[0]=0 offs[1]=0 for i=1,14
do offs[i+1]=offs[i]+count[i]end for i=0,n-1 do local l=lengths[from+i]or 0 if l~=0 then sym[offs[l] ]=i offs[l]+=1 end
end return{count=count,symbol=sym}end function Emotes.gunzip(data)local flg=string.byte(data,4)or 0 local pos=11 if
bit32.band(flg,4)~=0 then pos+=2+(string.byte(data,pos)or 0)+(string.byte(data,pos+1)or 0)*256 end if bit32.band(flg,8)
~=0 then pos=(string.find(data,'\0',pos,true)or#data)+1 end if bit32.band(flg,16)~=0 then pos=(string.find(data,'\0',pos
,true)or#data)+1 end if bit32.band(flg,2)~=0 then pos+=2 end local buf,cnt=0,0 local out={}local function bits(n)while
cnt<n do buf+=bit32.lshift(string.byte(data,pos)or 0,cnt)pos+=1 cnt+=8 end local v=bit32.band(buf,bit32.lshift(1,n)-1)
buf=bit32.rshift(buf,n)cnt-=n return v end local function decode(h)local code,first,index=0,0,0 for len=1,15 do code+=
bits(1)local c=h.count[len]if code-c<first then return h.symbol[index+(code-first)]end index+=c first=(first+c)*2 code*=
2 end error('bad huffman code')end repeat local final,typ=bits(1),bits(2)if typ==0 then buf,cnt=0,0 local len=(string.
byte(data,pos)or 0)+(string.byte(data,pos+1)or 0)*256 pos+=4 for i=0,len-1 do out[#out+1]=string.byte(data,pos+i)or 0
end pos+=len else local lens={}local nlen,ndist=288,30 if typ==1 then for i=0,143 do lens[i]=8 end for i=144,255 do lens
[i]=9 end for i=256,279 do lens[i]=7 end for i=280,287 do lens[i]=8 end for i=0,29 do lens[288+i]=5 end else nlen,ndist=
bits(5)+257,bits(5)+1 local ncode=bits(4)+4 local cl={}for i=1,ncode do cl[ORDER[i] ]=bits(3)end local clh=huff(cl,19,0)
local raw={}local i=0 while i<nlen+ndist do local s=decode(clh)if s<16 then raw[i]=s i+=1 else local rep,val=0,0 if s==
16 then val=raw[i-1]rep=3+bits(2)elseif s==17 then rep=3+bits(3)else rep=11+bits(7)end for _=1,rep do raw[i]=val i+=1
end end end for k=0,nlen-1 do lens[k]=raw[k]end for k=0,ndist-1 do lens[288+k]=raw[nlen+k]end end local lh,dh=huff(lens,
nlen,0),huff(lens,ndist,288)while true do local s=decode(lh)if s<256 then out[#out+1]=s elseif s==256 then break else s
-=257 local len=LBASE[s+1]+bits(LEXT[s+1])local ds=decode(dh)local dist=DBASE[ds+1]+bits(DEXT[ds+1])local start=#out-
dist for k=1,len do out[#out+1]=out[start+k]end end end end until final==1 local parts={}for i=1,#out,4096 do parts[#
parts+1]=string.char(table.unpack(out,i,math.min(i+4095,#out)))end return table.concat(parts)end local animIds=nil local
animations={}local function cache()local c=animIds if c then return c end local loaded={}for _,path in{OLD_CACHE,CACHE}
do local body=Env.readFile(path)local t=body and Env.json(body)if type(t)=='table'then for k,v in t do loaded[tostring(k
)]=tostring(v)end end end animIds=loaded return loaded end local function resolve(id)local key=tostring(id)local c=
cache()if c[key]then return c[key]end local animId=nil local res=Env.http(
'https://assetdelivery.roblox.com/v1/asset/?id='..key)if res and res.ok and res.body~=''then local body=res.body if
string.sub(body,1,2)=='\31\139'then local ok,raw=pcall(Emotes.gunzip,body)body=if ok then raw else''end animId=string.
match(body,'rbxassetid://(%d+)')or string.match(body,'[Aa]sset/%?[Ii][Dd]=(%d+)')end if not animId then local ok,objs=
pcall(function()return(game):GetObjects('rbxassetid://'..key)end)local a=if ok and type(objs)=='table'then objs[1]else
nil if typeof(a)=='Instance'and a:IsA('Animation')then animId=string.match(a.AnimationId,'(%d+)$')end end if animId then
c[key]=animId local ok,body=pcall(HttpService.JSONEncode,HttpService,c)if ok then Env.writeFile(CACHE,body)end end
return animId end function Emotes.animation(id)local a=animations[id]if a then return a end local animId=resolve(id)if
not animId then return nil end local anim=Instance.new('Animation')anim.Name='TZAR_Emote_'..id anim.AnimationId=
'rbxassetid://'..animId animations[id]=anim return anim end function Emotes.lookup(id)local info=Rules.productInfo(id)if
not info then return nil,false end if info.AssetTypeId~=EMOTE_ASSET_TYPE then return tostring(info.Name),false end
return tostring(info.Name),true end function Emotes.play(id)local char=Players.LocalPlayer.Character local hum=char and
char:FindFirstChildOfClass('Humanoid')if not(char and hum)then return false,'av.no_character'end if hum.RigType~=Enum.
HumanoidRigType.R15 then return false,'av.r15_only'end local anim=Emotes.animation(id)if not anim then return false,
'av.emote_failed'end local animate=char:FindFirstChild('Animate')local pe=animate and animate:FindFirstChild('PlayEmote'
)if pe and pe:IsA('BindableFunction')then local ok,res=pcall(pe.Invoke,pe,anim)if ok and res~=false then return true,nil
end end local animator=hum:FindFirstChildOfClass('Animator')if not animator then return false,'av.emote_failed'end local
track=animator:LoadAnimation(anim)track.Priority=Enum.AnimationPriority.Action track:Play()local conn conn=hum.Running:
Connect(function(speed)if speed>0.5 then track:Stop(0.2)conn:Disconnect()end end)track.Stopped:Once(function()if conn.
Connected then conn:Disconnect()end end)return true,nil end function Emotes.wheel(desc,list,outfitFirst)local out={}
local seen={}local function add(id,name,fromOutfit)if id and name and not seen[id]then seen[id]=true table.insert(out,{
id=id,name=name,fromOutfit=fromOutfit})end end if outfitFirst then local d=desc if not d then local hum=Players.
LocalPlayer.Character and Players.LocalPlayer.Character:FindFirstChildOfClass('Humanoid')local ok,applied=pcall(function
()return(hum):GetAppliedDescription()end)d=if ok then applied else nil end if d then local okE,emotes=pcall(function()
return(d):GetEmotes()end)local okQ,equipped=pcall(function()return(d):GetEquippedEmotes()end)if okE and okQ and type(
equipped)=='table'then local slots={}for _,it in equipped do local ids=emotes[it.Name]if ids and ids[1]and it.Slot>=1
and it.Slot<=SLOTS then slots[it.Slot]={id=ids[1],name=it.Name}end end for i=1,SLOTS do local s=slots[i]if s then add(s.
id,s.name,true)end end end end end for _,e in list do add(tonumber(e.id),e.name,false)end return out end return Emotes
end function __DARKLUA_BUNDLE_MODULES.ai()local v=__DARKLUA_BUNDLE_MODULES.cache.ai if not v then v={c=__modImpl()}
__DARKLUA_BUNDLE_MODULES.cache.ai=v end return v.c end end do local function __modImpl()local ContentProvider=game:
GetService('ContentProvider')local Players=game:GetService('Players')local Env=__DARKLUA_BUNDLE_MODULES.a()local Rules=
__DARKLUA_BUNDLE_MODULES.ah()local OWNED='TZAR_Look'local VERIFY_EVERY=0.5 local R15_PARTS={'Head','UpperTorso',
'LowerTorso','LeftUpperArm','LeftLowerArm','LeftHand','RightUpperArm','RightLowerArm','RightHand','LeftUpperLeg',
'LeftLowerLeg','LeftFoot','RightUpperLeg','RightLowerLeg','RightFoot'}local R6_PARTS={'Head','Torso','Left Arm',
'Right Arm','Left Leg','Right Leg'}local PART_VISUALS={SpecialMesh=true,FaceControls=true,WrapTarget=true,
SurfaceAppearance=true}local lp=Players.LocalPlayer local function own(inst)(inst):SetAttribute(OWNED,true)return inst
end local function isOwned(inst)return inst:GetAttribute(OWNED)==true end local function isPartVisual(x)return
PART_VISUALS[x.ClassName]==true or(x:IsA('Decal')and x.Name=='face')end local function isAvatarAccessory(x)if not x:IsA(
'Accoutrement')then return false end local h=x:FindFirstChild('Handle')return h~=nil and h:IsA('BasePart')end local 
function isAppearanceItem(x)return x:IsA('Clothing')or x:IsA('ShirtGraphic')or x:IsA('BodyColors')or x:IsA(
'CharacterMesh')end local function accessories(model)local out={}for _,d in model:GetDescendants()do if
isAvatarAccessory(d)and not d:FindFirstAncestorWhichIsA('Tool')and not d:FindFirstAncestorWhichIsA('Accoutrement')then
table.insert(out,d)end end return out end local function partNames(hum)return if hum.RigType==Enum.HumanoidRigType.R15
then R15_PARTS else R6_PARTS end local function snapshot(char)for _,d in char:GetDescendants()do if not d.Archivable
then pcall(function()d.Archivable=true end)end end local prev=char.Archivable char.Archivable=true local c=char:Clone()
char.Archivable=prev for _,d in c:GetDescendants()do if d.ClassName=='Script'or d:IsA('Tool')then d:Destroy()end end
return c end local function syncPart(src,dst)if dst:IsA('MeshPart')and src:IsA('MeshPart')then if dst.MeshId~=src.MeshId
then pcall(function()dst.MeshId=src.MeshId end)end if dst.TextureID~=src.TextureID then pcall(function()dst.TextureID=
src.TextureID end)end local initial=Env.getHidden(src,'InitialSize')if initial then Env.setHidden(dst,'InitialSize',
initial)end end dst.Size=src.Size dst.Color=src.Color for _,c in dst:GetChildren()do if isPartVisual(c)then c:Destroy()
end end for _,c in src:GetChildren()do if isPartVisual(c)then own(c:Clone()).Parent=dst elseif c:IsA('Attachment')then
local a=dst:FindFirstChild(c.Name)if a and a:IsA('Attachment')then a.CFrame=c.CFrame else own(c:Clone()).Parent=dst end
elseif c:IsA('ValueBase')and(c.Name=='OriginalSize'or c.Name=='AvatarPartScaleType')then local v=dst:FindFirstChild(c.
Name)if v and v.ClassName==c.ClassName then(v).Value=(c).Value end end end end local function sourceMotor(src,m)local p1
=m.Part1 for _,d in src:GetDescendants()do if d:IsA('Motor6D')and d.Name==m.Name then local dp1=d.Part1 if dp1 and p1
and dp1.Name==p1.Name then return d end end end return nil end local function syncJoints(src,char)for _,m in char:
GetDescendants()do if m:IsA('Motor6D')then local p0,p1=m.Part0,m.Part1 if p0 and p1 and p0.Parent==char and p1.Parent==
char then local done=false for _,a1 in p1:GetChildren()do if a1:IsA('Attachment')and string.match(a1.Name,
'RigAttachment$')then local a0=p0:FindFirstChild(a1.Name)if a0 and a0:IsA('Attachment')then m.C0=a0.CFrame m.C1=a1.
CFrame done=true break end end end if not done then local sm=sourceMotor(src,m)if sm then m.C0=sm.C0 m.C1=sm.C1 end end
end end end end local function bodyAttachment(char,name)for _,p in char:GetChildren()do if p:IsA('BasePart')then local a
=p:FindFirstChild(name)if a and a:IsA('Attachment')then return a end end end return nil end local function 
attachAccessory(acc,char)local h=acc:FindFirstChild('Handle')if not h or not h:IsA('BasePart')then return end for _,j in
h:GetChildren()do if j:IsA('JointInstance')or j:IsA('WeldConstraint')then j:Destroy()end end h.Anchored=false h.
CanCollide=false h.Massless=true pcall(function()h.CanTouch=false h.CanQuery=false end)local w=Instance.new('Weld')w.
Name='AccessoryWeld'w.Part0=h for _,att in h:GetChildren()do if att:IsA('Attachment')then local target=bodyAttachment(
char,att.Name)if target then w.C0=att.CFrame w.C1=target.CFrame w.Part1=target.Parent break end end end if not w.Part1
then local head=char:FindFirstChild('Head')if not(head and head:IsA('BasePart'))then w:Destroy()return end w.C0=(acc).
AttachmentPoint w.C1=CFrame.new(0,head.Size.Y/2,0)w.Part1=head end w.Parent=h end local function animIds(sv)local t={}
for _,a in sv:GetChildren()do if a:IsA('Animation')then table.insert(t,a.AnimationId)end end return table.concat(t,';')
end local function copyAnimate(src,char,clips)local sA,dA=src:FindFirstChild('Animate'),char:FindFirstChild('Animate')if
not(sA and dA)then return end local changed=false for _,sv in sA:GetChildren()do local dv=dA:FindFirstChild(sv.Name)if
sv:IsA('StringValue')and dv and dv:IsA('StringValue')and animIds(sv)~=animIds(dv)then for _,c in dv:GetChildren()do c:
Destroy()end for _,c in sv:GetChildren()do c:Clone().Parent=dv end changed=true end end for slot,id in clips do local dv
=dA:FindFirstChild(slot)local a=dv and dv:FindFirstChildOfClass('Animation')local want='rbxassetid://'..id if a and a.
AnimationId~=want then a.AnimationId=want changed=true end end if changed and dA:IsA('LocalScript')then local hum=char:
FindFirstChildOfClass('Humanoid')local animator=hum and hum:FindFirstChildOfClass('Animator')if animator then for _,t in
animator:GetPlayingAnimationTracks()do t:Stop(0)end end dA.Enabled=false task.wait()dA.Enabled=true end end local 
function transplant(src,char,clips)local expect={}local hum=char:FindFirstChildOfClass('Humanoid')if not hum then return
expect end local isR15=hum.RigType==Enum.HumanoidRigType.R15 for _,n in partNames(hum)do local s,d=src:FindFirstChild(n)
,char:FindFirstChild(n)if s and d and s:IsA('BasePart')and d:IsA('BasePart')then syncPart(s,d)expect[d]={meshId=if d:
IsA('MeshPart')then d.MeshId else nil,size=d.Size,initial=if d:IsA('MeshPart')then Env.getHidden(d,'InitialSize')else
nil}end end local sRoot,dRoot=src:FindFirstChild('HumanoidRootPart'),char:FindFirstChild('HumanoidRootPart')if sRoot and
dRoot and sRoot:IsA('BasePart')and dRoot:IsA('BasePart')then for _,a in sRoot:GetChildren()do local d=if a:IsA(
'Attachment')then dRoot:FindFirstChild(a.Name)else nil if d and d:IsA('Attachment')then d.CFrame=(a).CFrame end end end
syncJoints(src,char)local srcHum=src:FindFirstChildOfClass('Humanoid')if isR15 and srcHum and sRoot and dRoot and sRoot:
IsA('BasePart')and dRoot:IsA('BasePart')then hum.HipHeight=srcHum.HipHeight+(sRoot.Size.Y-dRoot.Size.Y)/2 end for _,c in
char:GetChildren()do if isAppearanceItem(c)then c:Destroy()end end for _,acc in accessories(char)do acc:Destroy()end for
_,c in src:GetChildren()do if isAppearanceItem(c)then own(c:Clone()).Parent=char end end for _,c in accessories(src)do
local acc=own(c:Clone())attachAccessory(acc,char)acc.Parent=char end if isR15 then copyAnimate(src,char,clips or{})end
return expect end local Look={}function Look.new(log)local originals=(setmetatable({},{__mode='k'}))local fresh=(
setmetatable({},{__mode='k'}))local conns={lp.CharacterAdded:Connect(function(c)fresh[c]=false end),lp.
CharacterAppearanceLoaded:Connect(function(c)fresh[c]=true end)}local function waitAppearance(char)local t0=os.clock()if
fresh[char]==nil then while not lp:HasAppearanceLoaded()and os.clock()-t0<6 and lp.Character==char do task.wait(0.1)end
return end while fresh[char]==false and os.clock()-t0<8 and lp.Character==char do task.wait(0.1)end task.wait(0.3)end
local cur=nil local claimed=nil local busy=false local rules=false local alive=true local function build(desc,rig)local
copy=desc:Clone()local notes={}local post={clips={},scale=false}if rules then post=Rules.apply(copy,notes)end local ok,
built=Rules.call(Players,'CreateHumanoidModelFromDescription',copy,rig)copy:Destroy()if not ok or typeof(built)~=
'Instance'then error(tostring(built),0)end local model=built if rules then Rules.limit(model,post,notes)end pcall(
ContentProvider.PreloadAsync,ContentProvider,{model})return model,post.clips,notes end local function put(c)local char=
lp.Character local hum=char and char:FindFirstChildOfClass('Humanoid')if not(char and hum)then return{}end if not
originals[char]then originals[char]=snapshot(char)end local notes={}if not c.model or c.rig~=hum.RigType then if c.model
then c.model:Destroy()end local model,clips,n=build(c.desc,hum.RigType)c.model,c.clips,c.rig,notes=model,clips,hum.
RigType,n end c.expect=transplant(c.model,char,c.clips)c.char=char return notes end local function restore()local c=cur
if not c then return end cur=nil if c.model then c.model:Destroy()end local char=lp.Character local orig=char and
originals[char]if char and orig then transplant(orig,char,nil)end end local function changed(c)local char=lp.Character
if not char or c.char~=char then return false end local hum=char:FindFirstChildOfClass('Humanoid')if not hum then return
false end for _,n in partNames(hum)do local p=char:FindFirstChild(n)if p and p:IsA('BasePart')then local e=c.expect[p]if
not e then return true end if e.meshId and p:IsA('MeshPart')and p.MeshId~=e.meshId then return true end if(p.Size-e.size
).Magnitude>1e-3 then return true end local initial=e.initial and Env.getHidden(p,'InitialSize')if initial and e.initial
and(initial-e.initial).Magnitude>1e-3 then return true end for _,x in p:GetChildren()do if isPartVisual(x)and not
isOwned(x)then return true end end end end for _,x in char:GetChildren()do if isAppearanceItem(x)and not isOwned(x)then
return true end end for _,acc in accessories(char)do if not isOwned(acc)then return true end end return false end task.
spawn(function()while alive do task.wait(VERIFY_EVERY)local c=cur if alive and c and not busy and claimed==c.owner then
local ok,yes=pcall(changed,c)if ok and yes then busy=true local okPut,err=pcall(put,c)busy=false if not okPut then log(
'look: '..tostring(err))end end end end end)local self self={claim=function(owner)claimed=owner end,apply=function(owner
,desc,label)claimed=owner local char=lp.Character if char then waitAppearance(char)end local old=cur local c={owner=
owner,desc=desc,label=label,clips={},expect={}}busy=true local ok,notes=pcall(put,c)busy=false if not ok then if c.model
then c.model:Destroy()end error(notes,0)end if claimed~=owner then if c.model then c.model:Destroy()end return{}end if
old and old.model and old.model~=c.model then old.model:Destroy()end cur=c return notes end,release=function(owner)if
claimed~=owner then return end claimed=nil task.defer(function()if claimed==nil then restore()end end)end,owner=function
()local c=cur return if c then c.owner else nil end,current=function()local c=cur if c then return c.desc,c.label end
return nil,nil end,preview=function()local c=cur local src=if c and c.model then c.model else lp.Character if not src
then return nil end local ok,copy=pcall(snapshot,src)if not ok then return nil end for _,d in copy:GetDescendants()do if
d:IsA('LuaSourceContainer')or d:IsA('Sound')or d:IsA('ForceField')then d:Destroy()elseif d:IsA('BasePart')then d.
Anchored=true end end return copy end,setRules=function(on)if rules==on then return end rules=on local c=cur if c and
not busy then if c.model then c.model:Destroy()c.model=nil end busy=true local ok,err=pcall(put,c)busy=false if not ok
then log('look: '..tostring(err))end end end,destroy=function()alive=false for _,c in conns do c:Disconnect()end claimed
=nil restore()for _,m in originals do m:Destroy()end table.clear(originals)end}return self end return Look end function
__DARKLUA_BUNDLE_MODULES.aj()local v=__DARKLUA_BUNDLE_MODULES.cache.aj if not v then v={c=__modImpl()}
__DARKLUA_BUNDLE_MODULES.cache.aj=v end return v.c end end do local function __modImpl()local AssetService=game:
GetService('AssetService')local AvatarEditorService=game:GetService('AvatarEditorService')local HttpService=game:
GetService('HttpService')local Players=game:GetService('Players')local CtxTypes=__DARKLUA_BUNDLE_MODULES.m()local Data=
__DARKLUA_BUNDLE_MODULES.ag()local Emotes=__DARKLUA_BUNDLE_MODULES.ai()local Env=__DARKLUA_BUNDLE_MODULES.a()local
Janitor=__DARKLUA_BUNDLE_MODULES.j()local Look=__DARKLUA_BUNDLE_MODULES.aj()local Rules=__DARKLUA_BUNDLE_MODULES.ah()
local Signal=__DARKLUA_BUNDLE_MODULES.b()local SORTS={best='Bestselling',fav='MostFavorited',new='RecentlyCreated'}local
LOOKS={'wear','outfit','bundle'}local ADMIN_URL='https://hub.2md.space/tzar-admin.lua'local EXPORT_DIR='TZAR/exports/'
local DESC_CACHE=8 return function()local lp=Players.LocalPlayer local ctxRef=nil local data=nil local look=Look.new(
function(msg)local c=ctxRef if c then c.log:Error(msg)end end)local recent={}local changed=Signal.new()local source=nil
local function notify()task.defer(function()if not look.owner()then source=nil end changed:Fire()end)end local function 
store()local d=data if d then return d end local loaded,imported=Data.load()data=loaded local c=ctxRef if imported>0 and
c then c.log:Info(string.format('avatar: imported %d items from Avatar Changer',imported))end return loaded end local 
function remember(key,desc,label)for i,r in recent do if r.key==key then table.remove(recent,i)break end end table.
insert(recent,1,{key=key,desc=desc,label=label})while#recent>DESC_CACHE do table.remove(recent)end end local function 
cached(key)for _,r in recent do if r.key==key then return r end end return nil end local function wearLook(ctx,name,desc
,label,jan,from)look.claim(name)for _,other in LOOKS do if other~=name and ctx.isActive(other)then ctx.disable(other)end
end local char=ctx.character()if not char or not ctx.humanoid()then ctx.fail(ctx.t('av.no_character'))end local notes=
look.apply(name,desc,label)if#notes>0 then ctx.log:Info('avatar rules: '..table.concat(notes,', '))end source=from
notify()jan:Defer(function()look.release(name)notify()end)end local function resolveUser(ctx,text)local s=string.gsub(
string.gsub(text,'^%s+',''),'%s+$','')s=string.gsub(s,'^@','')local id=tonumber(s)if id then local okN,name=pcall(
Players.GetNameFromUserIdAsync,Players,id)return id,if okN and type(name)=='string'then name else s end local ok,found=
pcall(Players.GetUserIdFromNameAsync,Players,s)if ok and type(found)=='number'then return found,s end ctx.fail(ctx.t(
'av.not_found',s))return 0,s end local function serverLook(ctx,plr)local hum=plr.Character and plr.Character:
FindFirstChildOfClass('Humanoid')if not hum then ctx.fail(ctx.t('av.no_character_of',plr.Name))end local ok,desc=pcall(
function()return(hum):GetAppliedDescription()end)if ok then return desc end local child=(hum):FindFirstChildOfClass(
'HumanoidDescription')if not child then ctx.fail(ctx.t('av.no_character_of',plr.Name))end return child end local 
function currentDesc(ctx)local desc,label=look.current()if desc and label then return desc,label end local hum=ctx.
humanoid()if not hum then ctx.fail(ctx.t('av.no_character'))end local ok,mine=pcall(function()return(hum):
GetAppliedDescription()end)if not ok then ctx.fail(ctx.t('av.no_character'))end return mine,lp.Name end local function 
wheel()local d=store()local desc=look.current()return Emotes.wheel(desc,d.emotes,d.outfitEmotes)end local function 
exportScript(name,outfitData)local payload=table.clone(outfitData)payload.label=name return table.concat({
'-- TZAR outfit "'..name..'" ('..os.date('%d.%m.%Y %H:%M')..')',
[[-- Put this file in your executor's autoexec folder to wear the outfit on every join.]],'local OUTFIT = [==['..
HttpService:JSONEncode(payload)..']==]','if not game:IsLoaded() then game.Loaded:Wait() end',
'local Players = game:GetService("Players")','while not Players.LocalPlayer do task.wait() end',
'if not getgenv().TZAR_ADMIN then','\tlocal src = isfile("tzar-admin.lua") and readfile("tzar-admin.lua")',
'\t\tor game:HttpGet("'..ADMIN_URL..'")','\tloadstring(src)()','end',
'getgenv().TZAR_ADMIN.Module("avatar").ApplyOutfit(OUTFIT)',''},'\n')end local handlers={wear={enable=function(ctx,args,
jan)local who=args[1]local plr=if typeof(who)=='Instance'and(who):IsA('Player')then who else nil local key local desc
local label if plr then key='player:'..plr.UserId local hit=cached(key)if hit and not(plr.Parent and plr.Character)then
desc,label=hit.desc,hit.label else desc,label=serverLook(ctx,plr),plr.Name end else local id,name=resolveUser(ctx,
tostring(who))key='user:'..id local hit=cached(key)if hit then desc,label=hit.desc,hit.label else local ok,got=Rules.
call(Players,'GetHumanoidDescriptionFromUserId',id)if not ok or typeof(got)~='Instance'then ctx.fail(ctx.t(
'av.avatar_failed',name))end desc,label=got,name end end remember(key,desc,label)wearLook(ctx,'wear',desc,label,jan,if
plr then'server'else'profile')end},outfit={enable=function(ctx,args,jan)local o=Data.find(store(),tostring(args[1]))if
not o then ctx.fail(ctx.t('arg.outfit',tostring(args[1])))end local outfit=o local key='outfit:'..outfit.id local hit=
cached(key)local desc=if hit then hit.desc else Data.deserialize(outfit.data)remember(key,desc,outfit.name)wearLook(ctx,
'outfit',desc,outfit.name,jan,'outfit')end},bundle={enable=function(ctx,args,jan)local id=tonumber(string.match(
tostring(args[1]),'%d+')or'')if not id then ctx.fail(ctx.t('av.bundle_bad',tostring(args[1])))end local bundleId=id
local key='bundle:'..bundleId local hit=cached(key)local desc local label if hit then desc,label=hit.desc,hit.label else
local ok,details=pcall(AssetService.GetBundleDetailsAsync,AssetService,bundleId)if not ok or type(details)~='table'then
ctx.fail(ctx.t('av.bundle_bad',tostring(bundleId)))end local outfitId=nil for _,it in(details).Items do if it.Type==
'UserOutfit'and(it.Name==(details).Name or not outfitId)then outfitId=it.Id end end if not outfitId then ctx.fail(ctx.t(
'av.bundle_bad',tostring(bundleId)))end local okD,got=Rules.call(Players,'GetHumanoidDescriptionFromOutfitId',outfitId)
if not okD or typeof(got)~='Instance'then ctx.fail(ctx.t('av.avatar_failed',tostring((details).Name)))end desc,label=got
,tostring((details).Name)end remember(key,desc,label)wearLook(ctx,'bundle',desc,label,jan,'bundle')end},saveoutfit={run=
function(ctx,args)local desc,label=currentDesc(ctx)local d=store()local given=args[1]and string.match(tostring(args[1]),
'^%s*(.-)%s*$')local name=Data.unique(d,if given and given~=''then given else label)table.insert(d.outfits,{id=
HttpService:GenerateGUID(false),name=name,data=Data.serialize(desc)})Data.save(d)notify()ctx.toast('ok',ctx.t(
'av.outfit_saved',name))end},renameoutfit={run=function(ctx,args)local d=store()local o=Data.find(d,tostring(args[1]))if
not o then ctx.fail(ctx.t('arg.outfit',tostring(args[1])))end local outfit=o local new=string.match(tostring(args[2]),
'^%s*(.-)%s*$')or''if new==''then ctx.fail(ctx.t('arg.missing','name'))end local old=outfit.name outfit.name=if string.
lower(new)==string.lower(old)then new else Data.unique(d,new)Data.save(d)notify()ctx.toast('ok',ctx.t(
'av.outfit_renamed',old,outfit.name))end},deloutfit={run=function(ctx,args)local d=store()local o=Data.find(d,tostring(
args[1]))if not o then ctx.fail(ctx.t('arg.outfit',tostring(args[1])))end local outfit=o if ctx.isActive('outfit')and
look.owner()=='outfit'then local _,label=look.current()if label==outfit.name then ctx.disable('outfit')end end table.
remove(d.outfits,(table.find(d.outfits,outfit)))Data.save(d)notify()ctx.toast('ok',ctx.t('av.outfit_deleted',outfit.name
))end},outfits={run=function(ctx)local names={}for _,o in store().outfits do table.insert(names,o.name)end if#names==0
then ctx.toast('info',ctx.t('av.outfits_none'))else ctx.toast('info',ctx.t('av.outfits_list',table.concat(names,', ')))
end end},exportoutfit={run=function(ctx,args)local name local outfitData if args[1]then local o=Data.find(store(),
tostring(args[1]))if not o then ctx.fail(ctx.t('arg.outfit',tostring(args[1])))end name,outfitData=(o).name,(o).data
else local desc,label=currentDesc(ctx)name,outfitData=label,Data.serialize(desc)end local source=exportScript(name,
outfitData)local file=EXPORT_DIR..string.gsub(name,'[^%w_%-]','_')..'.lua'local saved=Env.writeFile(file,source)local
copied=Env.clipboard(source)if not saved and not copied then ctx.fail(ctx.t('av.export_failed'))end ctx.toast('ok',ctx.
t(if copied then'av.exported'else'av.exported_file',file))end},avatarrules={enable=function(_ctx,_args,jan)look.
setRules(true)jan:Defer(function()look.setRules(false)end)end},emote={run=function(ctx,args)local token=tostring(args[1]
)local id=tonumber(token)if not id then for _,e in wheel()do if string.lower(e.name)==string.lower(token)then id=e.id
break end end end if not id then ctx.fail(ctx.t('arg.emote',token))end local ok,why=Emotes.play(id)if not ok then ctx.
fail(ctx.t(why or'av.emote_failed',token))end end},addemote={run=function(ctx,args)local id=tonumber(string.match(
tostring(args[1]),'(%d+)')or'')if not id then ctx.fail(ctx.t('av.not_emote',tostring(args[1])))end local d=store()for _,
e in d.emotes do if e.id==id then ctx.toast('info',ctx.t('av.emote_exists',e.name))return end end local title,isEmote=
Emotes.lookup(id)if not title then ctx.fail(ctx.t('av.asset_missing',tostring(id)))end if not isEmote then ctx.fail(ctx.
t('av.not_emote',tostring(title)))end local given=args[2]and string.match(tostring(args[2]),'^%s*(.-)%s*$')local name=if
given and given~=''then given else tostring(title)table.insert(d.emotes,{id=id,name=name})Data.save(d)notify()ctx.toast(
'ok',ctx.t('av.emote_added',name))end},delemote={run=function(ctx,args)local token=tostring(args[1])local d=store()local
id=tonumber(token)for i,e in d.emotes do if e.id==id or string.lower(e.name)==string.lower(token)then table.remove(d.
emotes,i)Data.save(d)notify()ctx.toast('ok',ctx.t('av.emote_removed',e.name))return end end ctx.fail(ctx.t('arg.emote',
token))end},emotes={run=function(ctx)local names={}for _,e in wheel()do table.insert(names,e.name)end if#names==0 then
ctx.toast('info',ctx.t('av.emotes_none'))else ctx.toast('info',ctx.t('av.emotes_list',table.concat(names,', ')))end end}
,avatar={run=function(ctx)ctx.openView('avatar')end},emotewheel={run=function(ctx)ctx.openView('emotewheel')end}}local 
function items(page)local out={}if type(page)~='table'then return out end for _,it in page do local id=type(it)=='table'
and tonumber(it.Id)if id and it.Name then table.insert(out,{id=id,name=tostring(it.Name)})end end return out end local 
function search(query,sort)local params=nil local okP=pcall(function()params=(CatalogSearchParams).new()params.
BundleTypes={Enum.BundleType.BodyParts}if string.match(query,'%S')then params.SearchKeyword=query end end)if not okP
then return nil end pcall(function()params.SortType=(Enum.CatalogSortType)[SORTS[sort or'best']or'Bestselling']end)local
ok,pages=Rules.call(AvatarEditorService,'SearchCatalog',params)if not ok or typeof(pages)~='Instance'then return nil end
local p=pages local okFirst,first=pcall(function()return p:GetCurrentPage()end)return{items=if okFirst then items(first)
else{},finished=function()local okF,done=pcall(function()return p.IsFinished end)return not okF or done==true end,next=
function()local okN,page=pcall(function()if p.IsFinished then return nil end p:AdvanceToNextPageAsync()return p:
GetCurrentPage()end)return if okN then items(page)else{}end}end local api={ApplyOutfit=function(json)local c=ctxRef if
not c then return end local ctx=c local t=if type(json)=='string'then Env.json(json)else json if type(t)~='table'then
ctx.toast('error',ctx.t('av.export_bad'))return end task.spawn(function()local char=lp.Character or lp.CharacterAdded:
Wait()char:WaitForChild('Humanoid',10)local d=store()local name=tostring(t.label or'Autoexec')local o=Data.find(d,name)
local payload=table.clone(t)payload.label=nil if o then o.data=payload else table.insert(d.outfits,{id=HttpService:
GenerateGUID(false),name=name,data=payload})end Data.save(d)notify()for i=#recent,1,-1 do if string.sub(recent[i].key,1,
7)=='outfit:'then table.remove(recent,i)end end local ok,msg=ctx.run('outfit "'..name..'"')if not ok and msg then ctx.
toast('error',msg)end end)end,Reset=function()local c=ctxRef if c then for _,name in LOOKS do if c.isActive(name)then c.
run('un'..name)end end end end,Changed=changed,State=function()local _,label=look.current()return{owner=look.owner(),
label=label,source=source}end,Outfits=function()local out={}for _,o in store().outfits do table.insert(out,o.name)end
return out end,Wheel=function()return wheel()end,OutfitEmotes=function()return store().outfitEmotes end,SetOutfitEmotes=
function(on)local d=store()d.outfitEmotes=on Data.save(d)notify()end,Preview=function()return look.preview()end,Search=
search}return{handlers=handlers,api=api,init=function(ctx,jan)ctxRef=ctx jan:Defer(function()look.destroy()changed:
DisconnectAll()end)end,lists={outfit=function()local out={}for _,o in store().outfits do table.insert(out,o.name)end
return out end,emote=function()local out={}for _,e in wheel()do table.insert(out,e.name)end return out end}}end end
function __DARKLUA_BUNDLE_MODULES.ak()local v=__DARKLUA_BUNDLE_MODULES.cache.ak if not v then v={c=__modImpl()}
__DARKLUA_BUNDLE_MODULES.cache.ak=v end return v.c end end do local function __modImpl()local Lighting=game:GetService(
'Lighting')local Players=game:GetService('Players')local CtxTypes=__DARKLUA_BUNDLE_MODULES.m()local Janitor=
__DARKLUA_BUNDLE_MODULES.j()local TONES={neutral=Color3.new(1,1,1),warm=Color3.fromRGB(255,226,196),cold=Color3.fromRGB(
205,225,255),mono=Color3.new(1,1,1)}local function correction(jan)local cc=Instance.new('ColorCorrectionEffect')cc.Name=
'TZAR_Sandbox'cc.Parent=Lighting jan:Add(cc)return cc end local function hold(jan,target,prop,value)jan:Set(target,prop,
value)jan:Connect(target:GetPropertyChangedSignal(prop),function()if(target)[prop]~=value then(target)[prop]=value end
end)end return function()local features={brightness={enable=function(_ctx,v,jan)hold(jan,Lighting,'Brightness',v)end},
nofog={enable=function(_ctx,_v,jan)hold(jan,Lighting,'FogEnd',1e9)for _,a in Lighting:GetChildren()do if a:IsA(
'Atmosphere')then jan:Set(a,'Density',0)jan:Set(a,'Haze',0)end end end},night={enable=function(_ctx,_v,jan)hold(jan,
Lighting,'ClockTime',0)end},tone={enable=function(_ctx,v,jan)local cc=correction(jan)cc.TintColor=TONES[v]or TONES.
neutral cc.Saturation=if v=='mono'then-1 else 0 end},contrast={enable=function(_ctx,v,jan)correction(jan).Contrast=v end
},noshadows={enable=function(_ctx,_v,jan)hold(jan,Lighting,'GlobalShadows',false)end},fov={enable=function(_ctx,v,jan)
local cam=workspace.CurrentCamera if cam then hold(jan,cam,'FieldOfView',v)end end},zoom={enable=function(_ctx,v,jan)jan
:Set(Players.LocalPlayer,'CameraMaxZoomDistance',v)end},camclip={enable=function(_ctx,_v,jan)jan:Set(Players.LocalPlayer
,'DevCameraOcclusionMode',Enum.DevCameraOcclusionMode.Invisicam)end},delay={enable=function()end},loop={enable=function(
)end},fromNearest={enable=function()end},announce={enable=function()end}}local function run(ctx,r,_jan)local names=ctx.
listOf('waypoint')if#names==0 then r.status(ctx.t('m.sandbox.no_waypoints'))r.wait(3)return end repeat local start=1 if
r.value('fromNearest')then local root=ctx.root()local best,bestD=1,math.huge for i,name in names do local p=ctx.
waypoint(name)if root and p then local d=(root.Position-p).Magnitude if d<bestD then best,bestD=i,d end end end start=
best end for step=0,#names-1 do local i=(start+step-1)%#names+1 local name=names[i]r.status(ctx.t('m.sandbox.at',i,#
names,name))r.progress((step+1)/#names)local root,p=ctx.root(),ctx.waypoint(name)if root and p then root.
AssemblyLinearVelocity=Vector3.zero root.CFrame=CFrame.new(p)*root.CFrame.Rotation end if r.value('announce')then ctx.
toast('info',ctx.t('m.sandbox.at',i,#names,name))end if not r.wait(tonumber(r.value('delay'))or 3)then return end end
until not r.value('loop')r.status(ctx.t('m.sandbox.done'))end return{features=features,run=run}end end function
__DARKLUA_BUNDLE_MODULES.al()local v=__DARKLUA_BUNDLE_MODULES.cache.al if not v then v={c=__modImpl()}
__DARKLUA_BUNDLE_MODULES.cache.al=v end return v.c end end end local T0=os.clock()local Players=game:GetService(
'Players')if not game:IsLoaded()then game.Loaded:Wait()end while not Players.LocalPlayer do task.wait()end local Env=
__DARKLUA_BUNDLE_MODULES.a()local genv=Env.genv()local previous=genv.TZAR_ADMIN if type(previous)=='table'and type(
previous.Unload)=='function'then pcall(previous.Unload)end local App=__DARKLUA_BUNDLE_MODULES.N()local Binds=
__DARKLUA_BUNDLE_MODULES.O()local Commands=__DARKLUA_BUNDLE_MODULES.aa()local CtxTypes=__DARKLUA_BUNDLE_MODULES.m()local
HubImpl=__DARKLUA_BUNDLE_MODULES.ab()local I18n=__DARKLUA_BUNDLE_MODULES.d()local Janitor=__DARKLUA_BUNDLE_MODULES.j()
local Log=__DARKLUA_BUNDLE_MODULES.e()local Modules=__DARKLUA_BUNDLE_MODULES.o()local Registry=__DARKLUA_BUNDLE_MODULES.
n()local Scheduler=__DARKLUA_BUNDLE_MODULES.k()local Store=__DARKLUA_BUNDLE_MODULES.l()local Assets=
__DARKLUA_BUNDLE_MODULES.q()local Theme=__DARKLUA_BUNDLE_MODULES.r()local lp=Players.LocalPlayer local log=Log.new()
local hub=Janitor.new(function(msg)log:Error(msg)end)local store=Store.new()local i18n=I18n.new(I18n.detect(store.data.
lang))for _,bundle in Commands.strings do i18n:Register(bundle)end local function t(key,...)return i18n:T(key,...)end
local scheduler=Scheduler.new()local app=nil local unloaded=false local readyMs=0 local registry local modules local
unload local hooks={unload=function()unload()end,setDisabled=function(name,disabled)registry:SetDisabled(name,disabled)
store:Save('disabled')end,spec=function(name)return registry:Get(name)end,count=function()return#registry.specs end,
setLang=function(lang)if i18n:SetLang(lang)then store.data.lang=lang store:Save('lang')end end,togglePreset=function(key
)local mod,p=modules:FindPreset(key)if not mod or not p then return nil,nil end modules:TogglePreset(mod,p.id)return
modules:PresetActive(mod,p.id),modules:PresetTitle(mod,p)end}local loaders={hub=function()return HubImpl(hooks)end,
character=function()return __DARKLUA_BUNDLE_MODULES.af()()end,avatar=function()return __DARKLUA_BUNDLE_MODULES.ak()()end
}registry=Registry.new(Commands.specs,loaders,store.data.disabled)modules=Modules.new(Commands.games,{sandbox=function()
return __DARKLUA_BUNDLE_MODULES.al()()end},registry,store)registry:SetList('module',function()local out={}for _,s in
modules:Available()do table.insert(out,s.id)end return out end)registry:SetList('preset',function()return modules:
PresetKeys()end)local function character()return lp.Character end local function waypoint(name)local body=Env.readFile(
'TZAR/admin/waypoints.json')local data=body and Env.json(body)local here=type(data)=='table'and data[tostring(game.
PlaceId)]local pt=type(here)=='table'and here[name]if type(pt)=='table'and type(pt.x)=='number'then return Vector3.new(
pt.x,pt.y,pt.z)end return nil end local ctx={t=t,toast=function(kind,text)if app then app.toast(kind,text)end end,fail=
Registry.fail,log=log,store=store,i18n=i18n,scheduler=scheduler,hub=hub,run=function(line)return registry:Run(line)end,
isActive=function(name)return registry:IsActive(name)end,disable=function(name)registry:Disable(name)end,setList=
function(kind,provider)registry:SetList(kind,provider)end,openView=function(view)if app then app.openView(view)end end,
openModule=function(id)if app then app.openModule(id)end end,listOf=function(kind)return registry:List(kind)end,waypoint
=waypoint,character=character,humanoid=function()local c=lp.Character return if c then c:FindFirstChildOfClass(
'Humanoid')else nil end,root=function()local c=lp.Character local r=c and c:FindFirstChild('HumanoidRootPart')return if
r and r:IsA('BasePart')then r else nil end}registry:SetCtx(ctx)modules:SetCtx(ctx)local binds=Binds.new(store,{toggleAll
=function()if app then app.toggleAll()end end,openBar=function()if app then app.openBar(nil)end end,run=function(line)
task.spawn(function()local ok,msg=registry:Run(line,'bind')if not ok and msg then ctx.toast('error',msg)end end)end})
local function info()local name,ver=Env.executor()return t('set.info',name,ver,math.floor(readyMs+0.5),#registry.specs)
end app=App.new({parent=Env.guiParent(),registry=registry,modules=modules,store=store,i18n=i18n,log=log,t=t,run=function
(line)return registry:Run(line,'palette')end,capture=function(fn)binds:Capture(fn)end,info=info,unload=function()unload(
)end})hub:Connect(lp.Chatted,function(msg)if store.data.chatCommands and string.sub(msg,1,1)==';'then local ok,err=
registry:Run(string.sub(msg,2),'chat')if not ok and err then ctx.toast('error',err)end end end)unload=function()if
unloaded then return end unloaded=true modules:Destroy()registry:Destroy()binds:Destroy()hub:Cleanup()if app then app.
destroy()app=nil end scheduler:Destroy()store:Destroy()i18n:Destroy()log:Destroy()if genv.TZAR_ADMIN and genv.TZAR_ADMIN
.Unload==unload then genv.TZAR_ADMIN=nil end end readyMs=(os.clock()-T0)*1000 log:Info(string.format('ready in %.1f ms',
readyMs))genv.TZAR_ADMIN={Version=Commands.VERSION,StartMs=readyMs,Unload=unload,Run=function(line)return registry:Run(
line,'api')end,IsActive=function(name)return registry:IsActive(name)end,Value=function(name)return registry:Value(name)
end,Specs=function()return registry.specs end,Modules=function()return modules end,Module=function(name)return registry:
Api(name)end,T=function(key,...)return t(key,...)end,Debug=function()local ui=if app then app.debug()else{}ui.active=
registry:ActiveCount()ui.tickers=scheduler:Count()ui.hubTasks=hub:Count()ui.visible=if app then app.visible()else false
ui.lang=i18n.lang return ui end,App=function()return app end}task.defer(function()if not app then return end if Theme.
touch then app.notify(t('nt.title'),t('nt.touch'))else app.notify(t('nt.title'),t('nt.pc',';',store.data.toggleKey))end
end)Assets.download(Assets.missing(),function(got)if got>0 and not unloaded and app then Theme.loadFonts()app.rebuild()
end end)