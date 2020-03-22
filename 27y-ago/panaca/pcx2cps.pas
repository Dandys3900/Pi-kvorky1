{ (c) 05.07.1994 by Mr.Old, ver. 1.01-Beta  }
uses crt,dos;
var f1,f2:file;
    p:array[1..32000] of byte;
    s1,s2:string;
    i,j,x1,x2,y1,y2:word;
    d:longint;
const head:array[1..128] of byte=(10,5,1,8,0,0,0,0,0,0,0,0,64,1,200,0,0,0,0,8,8,8,12,12,12,32,32,32,48,48,48,
	44,44,44,64,64,64,56,56,56,72,72,72,76,76,76,88,88,88,96,96,96,112,112,112,104,104,104,252,252,252,68,68,68,
	0,1,0,0,0,0,
	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0);
begin
if paramcount<1 then halt;
s1:=paramstr(1);assign(f1,s1);s2:=copy(s1,1,length(s1)-3)+'cpp';
assign(f2,s2);rewrite(f2,1);reset(f1,1);
blockread(f1,head,128);
p[1]:=head[5];p[2]:=head[7];p[3]:=head[9];p[4]:=head[11];
p[5]:=head[6]+head[10]*16;
blockwrite(f2,p,5);
repeat
blockread(f1,p,32000,i);blockwrite(f2,p,i,j);
until (i<>j) or (i=0);
close(f1);close(f2);
assign(f1,s2);assign(f2,(copy(s1,1,length(s1)-3)+'pal'));reset(f1,1);rewrite(f2,1);
seek(f1,(filesize(f1)-768));blockread(f1,p,768);for i:=1 to 768 do p[i]:=trunc(p[i]/4);
blockwrite(f2,p,768);
close(f1);close(f2);
assign(f1,s2);assign(f2,copy(s2,1,length(s2)-3)+'cps');reset(f1,1);rewrite(f2,1);
d:=filesize(f1)-769;while d-32000>0 do begin
	blockread(f1,p,32000);blockwrite(f2,p,32000);d:=d-32000;
end;
blockread(f1,p,d);blockwrite(f2,p,d);
close(f1);close(f2);
erase(f1);
end.