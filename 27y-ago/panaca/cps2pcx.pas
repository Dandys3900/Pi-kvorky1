{ (c) 05.07.1994 by Mr.Old, ver. 1.11  }
uses crt,dos;
var f1,f2,f3:file;
    p:array[1..32000] of byte;
    s1,s2,s3:string;
    i,j,x1,x2,y1,y2:word;
    d:longint;
const head:array[1..128] of byte=(10,5,1,8,0,0,0,0,0,0,0,0,64,1,200,0,0,0,0,8,8,8,12,12,12,32,32,32,48,48,48,
	44,44,44,64,64,64,56,56,56,72,72,72,76,76,76,88,88,88,96,96,96,112,112,112,104,104,104,252,252,252,68,68,68,
	0,1,0,0,0,0,
	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0);
      poz:array[1..58] of char='(c) by Mr. Old, ver. 1.11, 06.07.1994 converted by cps2pcx';
begin
if paramcount<1 then halt;
s1:=copy(paramstr(1),1,length(paramstr(1))-3);
s2:=s1+'cps';s3:=s1+'pal';s1:=s1+'pcx';
assign(f1,s1);assign(f2,s2);assign(f3,s3);
rewrite(f1,1);reset(f2,1);reset(f3,1);
blockread(f2,p,5);
head[5]:=p[1];head[7]:=p[2];head[9]:=p[3];head[11]:=p[4];head[10]:=trunc(p[5]/16);
p[5]:=p[5]-(trunc(p[5]/16)*16);head[6]:=p[5];
i:=(head[9]+256*head[10])-(head[5]+256*head[6])+1;head[68]:=trunc(i/256);
i:=i-(trunc(i/256)*256);head[67]:=i;
for i:=1 to 58 do head[i+70]:=ord(poz[i]);
for i:=1 to 128 do p[i]:=head[i];
blockwrite(f1,p,128);
repeat
blockread(f2,p,32000,i);blockwrite(f1,p,i,j);
until (i<>j) or (i=0);
p[1]:=12;blockwrite(f1,p,1);
blockread(f3,p,768);
for i:=1 to 768 do p[i]:=4*p[i];
blockwrite(f1,p,768);
close(f1);close(f2);close(f3);
end.