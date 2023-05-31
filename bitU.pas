unit bitU;
{ This program was created by Josh Greig to test and learn more about using assembly with scanline.
  The program tests 3 pixel formats but each uses almost exactly the same code.
  For each:
           1. Addresses of each row of pixels is stored in pa using ScanLine.
           2. In an assembly block, about 300 frames are looped through and for each frame,
           each pixel is set using the x-coordinate and frame number to define the colour.
           3. The bitmap is then drawn on the form to be seen by the user.
}

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ExtCtrls;

type
  TForm1 = class(TForm)
    Panel1: TPanel;
    Button2: TButton;
    Button1: TButton;
    Button3: TButton;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;
   bit: tbitmap;
   pa: array of pointer; // used to store pointers to rows of pixels in bit
implementation

{$R *.DFM}

procedure TForm1.FormCreate(Sender: TObject);
begin
     bit:=tbitmap.create;
     bit.height:=clientheight;
     bit.width:=clientwidth;
end;

procedure TForm1.FormDestroy(Sender: TObject);
begin
     bit.free;
end;

procedure TForm1.Button2Click(Sender: TObject);
var
  y,x,b,b2,z,ti: integer;
  p: pointer; // used to solve compatabilty problems between pa and pba
  pba: pbytearray;
  // used to temperarily store the address of the start of a row of pixels
begin
     panel1.hide;
     // -- store the information into arrays
     bit.pixelformat:=pf32bit; // make it so each pixel is stored in 4 bytes
     setlength(pa,bit.height);
     for x:=bit.height-1 downto 0 do
     begin // update pa
          pba:=bit.scanline[x]; // get the address of a row of pixels
          asm
             mov eax,dword ptr (pba);
             mov p,eax; // move the pointer value into p
             // this temperary value in p is just there because I don't know how
             // to move an address from a PByteArray into a normal pointer without
             // having incompatable errors
          end;
          pa[x]:=p;
     end;
     // -- finished storing the pointers
     x:=bit.width-1; // initial value in the loop through x-coordinates
     y:=high(pa); // initial value in the loop through y-coordinates
     ti:=gettickcount; // store the time
     for z:=0 to 300 do
     // loop through frames in the animation
     begin
       if z mod 10=0 then
          caption:='frame='+inttostr(z);
       asm
        // EAX stores the frame number
        // EBX stores the y-coordinate and the pixel colour
        // ECX stores the address of each row of pixels
        // EDX stores the x-coordinates
        mov b,ebx;
        // Ebx should be temperarily stored because Delphi uses its value.
        // If assembly code modifies ebx, it creates errors.
        mov ebx,y;
        mov eax,z;
        imul eax,eax;  // eax:=sqr(eax);
        // this is used to define the changing colours of the pixels for each frame
        @bigstart:  // loop through y-coordinates
             mov ecx,dword ptr (pa);        // get address of the contents of the array
             mov ecx,dword ptr (ecx+ebx*4);
             // get the address of a row of pixels

             mov b2,ebx; // temperarily store the value of ebx

             mov edx,x;
             @startloop: // loop through x-coordinates
                        mov ebx,edx;
                        imul ebx,eax; // eax's value is based on the frame number
                        // this is what causes the colour for each frame to be different
                        mov dword ptr (ecx+edx*4),ebx; // set the pixel
                  dec edx;
                  cmp edx,0;
                  jg @startloop;

             mov ebx,b2; // restore the value of ebx to the y-coordniate

          dec ebx;
          cmp ebx,0;
          jg @bigstart;
        mov ebx,b; // restore the value of ebx to its original value
       end;
       canvas.draw(0,0,bit); // draw the frame on the form
       // this draw sometimes is almost as time consuming as creating the frame
     end;
     ti:=gettickcount-ti; // get the number of miliseconds since the beginning of the animation
     canvas.draw(0,0,bit);
     caption:='animation took '+inttostr(ti)+'ms, height='+inttostr(bit.height)+
     ', width='+inttostr(bit.width)+', '+floattostr(ti/(bit.width*bit.height*z)*1000000)+'ns/pixel';
     panel1.Visible:=true;
end;

procedure TForm1.FormResize(Sender: TObject);
begin
     bit.height:=clientheight;
     bit.width:=clientwidth;
     // resize the bitmap
end;

procedure TForm1.Button1Click(Sender: TObject);
var
  y,x,b,b2,sp1,z,ti: integer;
  v: integer; // used to temperarily store edx
  p: pointer; // used to solve compatabilty problems between pa and pba
  pba: pbytearray;
  // used to temperarily store the address of the start of a row of pixels
begin
     panel1.hide;
     // -- store the information into arrays
     bit.pixelformat:=pf16bit; // make it so each pixel is stored in 2 bytes
     setlength(pa,bit.height);
     for x:=bit.height-1 downto 0 do
     begin // update pa
          pba:=bit.scanline[x]; // get the address of a row of pixels
          asm
             mov eax,dword ptr (pba);
             mov p,eax; // move the pointer value into p
             // this temperary value in p is just there because I don't know how
             // to move an address from a PByteArray into a normal pointer without
             // having incompatable errors
          end;
          pa[x]:=p;
     end;
     // -- finished storing the pointers
     x:=bit.width-1; // initial value in the loop through x-coordinates
     y:=high(pa); // initial value in the loop through y-coordinates
     ti:=gettickcount; // store the time
     for z:=0 to 300 do
     // loop through frames in the animation
     begin
       if z mod 10=0 then
          caption:='frame='+inttostr(z);
       asm


        mov b,ebx;
        // Ebx should be temperarily stored because Delphi uses its value.
        // If assembly code modifies ebx, it creates errors.
        mov ebx,y;
        mov eax,z;
        imul eax,eax;  // eax:=sqr(eax);
        // this is used to define the changing colours of the pixels for each frame
        @bigstart:  // loop through y-coordinates
             mov ecx,dword ptr (pa);        // get address of the contents of the array
             mov ecx,dword ptr (ecx+ebx*4);
             // get the address of a row of pixels

             mov b2,ebx; // temperarily store the value of ebx

             mov edx,x;
             @startloop: // loop through x-coordinates
                        mov ebx,edx;
                        imul ebx,eax; // eax's value is based on the frame number
                        // this is what causes the colour for each frame to be different
                        mov word ptr (ecx+edx*2),bx; // set the pixel
                  dec edx;
                  cmp edx,0;
                  jg @startloop;

             mov ebx,b2; // restore the value of ebx to the y-coordniate

          dec ebx;
          cmp ebx,0;
          jg @bigstart;
        mov ebx,b; // restore the value of ebx to its original value
       end;
       canvas.draw(0,0,bit); // draw the frame on the form
       // this draw sometimes is almost as time consuming as creating the frame
     end;
     ti:=gettickcount-ti; // get the number of miliseconds since the beginning of the animation
     canvas.draw(0,0,bit);
     caption:='animation took '+inttostr(ti)+'ms, height='+inttostr(bit.height)+
     ', width='+inttostr(bit.width)+', '+floattostr(ti/(bit.width*bit.height*z)*1000000)+'ns/pixel';
     panel1.Visible:=true;
end;

procedure TForm1.Button3Click(Sender: TObject);
var
  y,x,b,b2,sp1,z,ti: integer;
  v: integer; // used to temperarily store edx
  p: pointer; // used to solve compatabilty problems between pa and pba
  pba: pbytearray;
  // used to temperarily store the address of the start of a row of pixels
begin
     panel1.hide;
     // -- store the information into arrays
     bit.pixelformat:=pf8bit; // make it so each pixel is stored in 2 bytes
     setlength(pa,bit.height);
     for x:=bit.height-1 downto 0 do
     begin // update pa
          pba:=bit.scanline[x]; // get the address of a row of pixels
          asm
             mov eax,dword ptr (pba);
             mov p,eax; // move the pointer value into p
             // this temperary value in p is just there because I don't know how
             // to move an address from a PByteArray into a normal pointer without
             // having incompatable errors
          end;
          pa[x]:=p;
     end;
     // -- finished storing the pointers
     x:=bit.width-1; // initial value in the loop through x-coordinates
     y:=high(pa); // initial value in the loop through y-coordinates
     ti:=gettickcount; // store the time
     for z:=0 to 300 do
     // loop through frames in the animation
     begin
       if z mod 10=0 then
          caption:='frame='+inttostr(z);
       asm


        mov b,ebx;
        // Ebx should be temperarily stored because Delphi uses its value.
        // If assembly code modifies ebx, it creates errors.
        mov ebx,y;
        mov eax,z;
        imul eax,eax;  // eax:=sqr(eax);
        // this is used to define the changing colours of the pixels for each frame
        @bigstart:  // loop through y-coordinates
             mov ecx,dword ptr (pa);        // get address of the contents of the array
             mov ecx,dword ptr (ecx+ebx*4);
             // get the address of a row of pixels

             mov b2,ebx; // temperarily store the value of ebx

             mov edx,x;
             @startloop: // loop through x-coordinates
                        mov ebx,edx;
                        imul bl,al; // eax's value is based on the frame number
                        // this is what causes the colour for each frame to be different
                        mov byte ptr (ecx+edx),bl; // set the pixel
                  dec edx;
                  cmp edx,0;
                  jg @startloop;

             mov ebx,b2; // restore the value of ebx to the y-coordniate

          dec ebx;
          cmp ebx,0;
          jg @bigstart;
        mov ebx,b; // restore the value of ebx to its original value
       end;
       canvas.draw(0,0,bit); // draw the frame on the form
       // this draw sometimes is almost as time consuming as creating the frame
     end;
     ti:=gettickcount-ti; // get the number of miliseconds since the beginning of the animation
     canvas.draw(0,0,bit);
     caption:='animation took '+inttostr(ti)+'ms, height='+inttostr(bit.height)+
     ', width='+inttostr(bit.width)+', '+floattostr(ti/(bit.width*bit.height*z)*1000000)+'ns/pixel';
     panel1.Visible:=true;
end;

end.
