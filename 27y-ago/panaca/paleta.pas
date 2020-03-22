unit paleta;
interface
uses dos;
type paletatyp2=array[0..767] of byte;
     paletatyp=^paletatyp2;
procedure nastavpal(p:paletatyp);
procedure rychlezmiz;
procedure rychleobjevse;
procedure zmiz;
procedure objevse;
procedure paletaclose;
procedure paletainit;
procedure morfni(p:paletatyp;speed:byte);
function paletaprogress:boolean;
var userproc:procedure;
implementation
type paletatyp3=array[0..2301] of byte;
     paletatyp4=^paletatyp3;
var pa:paletatyp4;
    r:registers;
    i,j,k,l,prir,nakolik,krok,prir2:integer;
    oldcasint:procedure;
    menise,morfujese:boolean;
    mflag:word;
const maxprir=5;			{udava rychlost stmivani}
procedure obsluha;
var i:word;
begin
r.ah:=$10;r.al:=$12;r.bx:=0;r.cx:=256;r.es:=seg(pa^);r.dx:=ofs(pa^);
inc(nakolik,prir);if nakolik<0 then nakolik:=0;if nakolik>64 then nakolik:=64;
for i:=0 to 767 do mem[48+r.es:r.dx+i]:=(nakolik*(mem[r.es:r.dx+i] and 63)) shr 6;
if nakolik in [0,64] then begin prir:=0;menise:=false;end;inc(r.es,48);intr($10,r);
end;
{$F+}procedure noproc;
begin
end;{$F-}
procedure obsluhamorfu;
var i,j,k,l:word;
    pz,pc{zdroj,cil}:byte;
begin
r.ah:=$10;r.al:=$12;r.bx:=0;r.cx:=256;r.es:=seg(pa^);r.dx:=ofs(pa^);j:=r.es+48;k:=r.es+96;
inc(krok,prir2);if krok>64 then krok:=64;if krok<0 then krok:=0;
for i:=0 to 767 do begin
 l:=r.dx+i;pz:=mem[r.es:l];pc:=mem[k:l];
 if pc>pz then mem[j:l]:=pz+((krok*integer(pc-pz)) div 64) else
   mem[j:l]:=pz-((krok*integer(pz-pc)) div 64);
end;if krok=64 then begin morfujese:=false;move(pa^[1536],pa^,768);end;inc(r.es,48);intr($10,r);
end;
procedure newcasint;interrupt;
begin
if (menise) and (mflag=0) then begin
 mflag:=1;obsluha;mflag:=0;
end else
if (morfujese) and (mflag=0) then begin
 mflag:=1;obsluhamorfu;mflag:=0;
end;userproc;
inline($9c);oldcasint;
end;
{$F+}procedure nastavpal(p:paletatyp);
begin
r.ah:=$10;r.al:=$12;r.bx:=0;r.cx:=$100;r.es:=seg(p^);r.dx:=ofs(p^);intr($10,r);
move(p^,pa^,768);
end;
procedure morfni(p:paletatyp;speed:byte);
begin
move(p^,pa^[1536],768);krok:=0;prir2:=speed;morfujese:=true;
end;
function paletaprogress:boolean;
begin
paletaprogress:=menise or morfujese;
end;
procedure rychlezmiz;
begin
nakolik:=2;prir:=-2;menise:=true;
end;
procedure rychleobjevse;
begin
nakolik:=62;prir:=2;menise:=true;
end;
procedure zmiz;
begin
prir:=-maxprir;menise:=true;
end;
procedure objevse;
begin
prir:=maxprir;menise:=true;
end;{$F-}
procedure paletainit;
begin
mflag:=0;nakolik:=64;prir:=0;menise:=false;r.ah:=$10;r.al:=$17;r.bx:=0;
r.cx:=256;r.es:=seg(pa^);r.dx:=ofs(pa^);intr($10,r);prir2:=0;krok:=0;
getintvec($1c,@oldcasint);setintvec($1c,@newcasint);
end;
procedure paletaclose;
begin
setintvec($1c,@oldcasint);
end;
begin
getmem(pa,3*768);userproc:=noproc;
end.