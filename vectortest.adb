-- tests vectorPackage

with Text_IO;                       use Text_IO;
with Gnat.IO;                       use Gnat.IO;    
with Ada.Finalization;              use Ada.Finalization;
with Ada.Containers.Vectors;        

procedure vectortest IS
    subtype lexeme is integer;
    package Number is new Integer_IO(integer); USE Number;
    use Number;
    package LexVector is new Ada.Containers.Vectors
        (Index_Type => natural, Element_Type => lexeme);
    use LexVector;

    myVector    :   LexVector.Vector;
    lex         :   integer;
    elt         :   lexeme;
    idx         :   integer := 0;
BEGIN

INSERT:
    for i in 1..5 loop
    -- can be done either of the two following ways.
--        append(myVector, i);
        LexVector.Append(myVector, i);
    end loop INSERT;
    
    for elt of myVector loop
        put_line(item=> "idx :" & idx'img & myVector.Element(idx)'img);
        idx := idx+1;
    end loop;
    put(item=>"Vector Length :");
    lex := integer(length(myVector));
    put_line(item=>lex'img);
    -- using (tick)Img or Image allows you to use Put_line with a type
    -- (tick)img automatically inserts a space into the string
    -- & is used for string concatenation
    Text_IO.Put_Line ("Capacity :" & Lexvector.Capacity(myVector)'Img);
    
END vectorTest;
