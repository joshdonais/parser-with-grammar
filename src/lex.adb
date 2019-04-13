----
--	Author:         Joshua Donais                                         
--      Creation Date:  February 8, 2019                                        
--      Due Date:       February 13, 2019                                       
--      Course:         CSC310 010                                              
--      Professor:      Dr. Spiegel                                             
--      Assignment:     #2                                                      
--      Filename:       lex.adb                                                  
--      Purpose:        This program will scan an input file that represents a  
--                      program that follows a simplistic programming language  
--                      grammar to produce an output file that is an ordered    
--                      list of the symbole types found in the unput file.      
--      Time Spent on                                                           
--      Project (h):                                                            
--      Design:         6                                                       
--      Programming:    10                                                       
--      Testing:        3                                                       
--      Debugging:      8                                                       
------------------------------------------------------------------------------ 
--  @summary
--
--  @description

WITH Ada.Text_IO;                   USE Ada.Text_IO;
WITH OpenFile;                      USE OpenFile;
WITH Ada.Strings.Unbounded;         USE Ada.Strings.Unbounded;
WITH Ada.strings.Unbounded.Text_IO; USE Ada.Strings.Unbounded.Text_IO;
WITH Ada.Characters.Latin_1;        USE Ada.Characters.Latin_1;
WITH Ada.Command_Line;              USE Ada.Command_Line;

Procedure lex IS
    type toke is (PROGSYM, BEGINSYM, ENDSYM, DECSYM, COLN, SEMICOLN, COMMA,
        READSYM, WRITESYM, dTYPE, IDENT, LPAREN, RPAREN, ADD, SUBTRACT,
        MULTIPLY, DIVIDE, ASSIGN, NUM, UNKNOWN, OP);
    package Number is new Integer_IO(integer);  USE Number;
    package Class_IO is new Ada.Text_IO.Enumeration_IO(toke);
    -- Declarations
    inFile, outFile     :   file_type;
    CR                  :   constant character := Ada.Characters.Latin_1.CR;
    TAB                 :   constant character := Ada.characters.Latin_1.HT;
    token               :   toke;
    word                :   ada.strings.unbounded.unbounded_string;
    eof                 :   boolean := false;
    eol                 :   boolean := false;
    wordLen             :   natural := 0;


-----
--  writeToken
--  @pre
--  @param
--  @returns
Procedure writeToken(outFile :IN OUT file_type; token :IN OUT toke) IS
    BEGIN
        class_IO.Put(outFile, token);
        new_line(outFile);
    END writeToken;


Procedure tokenizeOp(char :IN character) IS
    
BEGIN
    case char is
        when '+' => token := ADD;
        when '-' => token := SUBTRACT;
        when '*' => token := MULTIPLY;
        when '/' => token := DIVIDE;
        when '=' => token := ASSIGN;
        when others => token := UNKNOWN;
    end case;
END tokenizeOP;
-----
--  tokenizeOther
--  @pre
--  @param
--  @returns
Procedure tokenizeOther(char :IN character) IS
    
    token       :   toke;
BEGIN
    case char is
        when ';' => token := SEMICOLN;
                    Class_IO.Put(token);
                    writeToken(outFile, token);
                    new_line;
        when ':' => token := COLN;
                    Class_IO.Put(token);
                    writeToken(outFile, token);
                    new_line;
        when ',' => token := COMMA;
                    Class_IO.Put(token);
                    writeToken(outFile, token);
                    new_line;
        when '(' => token := LPAREN;
                    Class_IO.Put(token);
                    writeToken(outFile, token);
                    new_line;
        when ')' => token := RPAREN;
                    Class_IO.Put(token);
                    writeToken(outFile, token);
                    new_line;
        when ' ' | '.' => null;
        when others => token:= OP;
                    Class_IO.Put(token);
                    writeToken(outFile, token);
                    new_line;
                    
    end case;

END tokenizeOther;


-----
--  tokenizeLower
--  Checks if selected alpha characters will be keywords 'program, begin, dec,
--      end.  
--  @pre
--  @param
--  @return
Procedure tokenizeLower (inFile :IN OUT file_type; outFile :IN OUT file_type;
    word :IN ada.strings.unbounded.unbounded_string; eof :OUT boolean;
    char :IN character) IS

    token           :   toke;
BEGIN
        
    if word = "end" then
        if char = '.' then
            token := ENDSYM;
            eof := true;
        end if;
    elsif word = "begin" then
        token := BEGINSYM;
    elsif word = "dec" then
        token := DECSYM;
    elsif word = "program" then
        token := PROGSYM;
    else
        token := IDENT;
    end if;
    class_IO.Put(token);
    writeToken(outFile, token);
    new_line;
END tokenizeLower;
    

-----
--  tokenizeUpper
--  Takes in uppercase alphabetical character and checks if 'Read' or 'Write'
--  @pre 
--  @param
--  @return
Procedure tokenizeUpper (inFile :IN OUT file_type; outFile :IN OUT file_type;
    word :IN OUT ada.strings.unbounded.unbounded_string;
    char :IN OUT character) IS
   
    readLen     :   integer:= 4-1; -- minus first char used to enter prev switch
    writeLen    :   integer:= 5-1;
    token       :   toke;
    idx         :   integer := 1;
BEGIN
    if length(word) = 0 then -- make sure word is empty
        case char is
            when 'R' => token := READSYM;
                        Class_IO.Put(token);
                        writeToken(outFile, token);
                        new_line;
                        for idx in 1..readLen loop
                            get(file=>inFile, item=>char);
                        end loop;
            when 'W' => token := WRITESYM; 
                        Class_IO.Put(token);
                        writeToken(outFile, token);
                        new_line;
                        for idx in 1..writeLen loop
                            get(file=>inFile, item=>char);
                        end loop;
            when others => Put_Line(item=>"tokenizeUpper Error");
        end case;
    end if;
END tokenizeUpper;



-----
--  tokenize
--  @pre
--  @param
--  @returns
Procedure tokenize(inFile :IN OUT file_type; outFile :IN OUT file_type;
    word :IN OUT ada.strings.unbounded.unbounded_string; char :IN OUT character;
    eol :IN OUT boolean; eof :OUT boolean) IS

BEGIN
LINE:   while not Ada.Text_IO.End_of_Line (inFile) loop
            look_Ahead(inFile, char, eol);
            if char = CR then
                wordLen := length(word);
                if wordLen /= 0 then    -- semi colon CR requires this
                    tokenizeLower(inFile, outFile, word, eof, char);
                    delete(word, 1, length(word));
                end if; 
                get(file=>inFile, item=>char);
                exit;
            else
                get(file=>inFile, item=>char);
                case char is
                    when 'a'..'z'   =>  word := word & char;
                    when 'A'..'Z'   =>  tokenizeUpper(inFile, outFile, 
                                          word, char);
                    when '0'..'9'   =>  word := word & char;
                    when others =>  if char = TAB then
                                        exit;
                                    else
                                        wordLen := length(word);
                                        if wordLen /= 0 then
                                            tokenizeLower(inFile, outFile, 
                                                word,eof, char);
                                            delete(word, 1, length(word));
                                        end if;
                                        tokenizeOther(char);
                                    end if;
                end case;
            end if;
        end loop LINE;
END tokenize;

    char                :   character;
--------------------------------------------
-- Main Procedure
--------------------------------------------
BEGIN

    put_line("Form: lex <sourcefile> <destfile>");
    if argument_count /= 2 then
        openReadFile(inFile);
        put_line("Token Destination: ");
        openWriteFile(outFile);
    elsif argument_count = 2 then
       open(file=>inFile, mode=> in_file, name=>argument(1));
       create(file=>outFile, mode=>out_file, name=>argument(2));
    end if;
FILE:
    while not eof loop
           tokenize(inFile, outFile, word, char, eol, eof);
        
        if char = CR or Ada.Text_IO.End_of_Line (inFile) then
            skip_line(inFile);
        end if;
        end loop FILE;
close(inFile);
close(outFile);


END lex;
