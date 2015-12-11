MODULE Main;
FROM XTerm IMPORT SEQ,ESCAPE,AskTermType,ResetTerm,
                  ClrScr,PlotBox,Center,HideCursor,ShowCursor,CursorXY,
                  ClrEol,RandomizeShuffle;
FROM Terminal IMPORT ReadChar;
FROM Game IMPORT StartGame,playerName1,playerName2,totalScore,g;

VAR choose:INTEGER;

PROCEDURE Clear(x,y:CARDINAL);
CONST s
  ='                                                                       ';
VAR i:CARDINAL;
BEGIN
 FOR i:=x TO y DO
   CursorXY(5,i);
   WRITE(s);
 END
END Clear;

PROCEDURE IntroScreen();
CONST x=8;
CONST y=5;
BEGIN
  IF choose=1 THEN
    ClrScr;
    WRITE(SEQ[RED]);
    PlotBox(4,2,77,23,FALSE,TRUE);
    PlotBox(3,2,78,23,TRUE,TRUE)
  ELSE
    Clear(3,22)
  END;

  WRITE(SEQ[YELLOW]);

  CursorXY(x+46,y+0);
  WRITE(SEQ[REVERSE],'     ',SEQ[PLAIN],'    ',SEQ[REVERSE],'  ',SEQ[PLAIN],'    ',
  SEQ[REVERSE],'    ');

  CursorXY(x+46,y+1);
  WRITE(SEQ[REVERSE],'  ',SEQ[PLAIN],'  ',SEQ[REVERSE],'  ',SEQ[PLAIN],'  ',
  SEQ[REVERSE],'    ',SEQ[PLAIN],'  ',SEQ[REVERSE],'  ',SEQ[PLAIN],'  ',
  SEQ[REVERSE],'  ');

  CursorXY(x+46,y+2);
  WRITE(SEQ[REVERSE],'  ',SEQ[PLAIN],'  ',SEQ[REVERSE],'  ',SEQ[PLAIN],' ',
  SEQ[REVERSE],'  ',SEQ[PLAIN],'  ',SEQ[REVERSE],'  ',SEQ[PLAIN],' ',SEQ[REVERSE],'  ');

  CursorXY(x,y+3);
  WRITELN(SEQ[PLAIN],' ',SEQ[REVERSE],'    ',SEQ[PLAIN],'   ',SEQ[REVERSE],'    ',
  SEQ[PLAIN],'  ',SEQ[REVERSE],'     ',SEQ[PLAIN],'  ',SEQ[REVERSE],'  ',
  SEQ[PLAIN],' ',SEQ[REVERSE],'  ',SEQ[PLAIN],'    ',SEQ[REVERSE],'  ',SEQ[PLAIN],
  '     ',SEQ[REVERSE],'    ',SEQ[PLAIN],'     ',SEQ[REVERSE],'     ',SEQ[PLAIN],
  '  ',SEQ[REVERSE],'      ',SEQ[PLAIN],'  ',SEQ[REVERSE],'    ');

  CursorXY(x,y+4);
  WRITELN(SEQ[REVERSE],'  ',SEQ[PLAIN],'     ',SEQ[REVERSE],'  ',SEQ[PLAIN],'  ',
  SEQ[REVERSE],'  ',SEQ[PLAIN],' ',SEQ[REVERSE],'  ',SEQ[PLAIN],'  ',SEQ[REVERSE],
  '  ',SEQ[PLAIN],' ',SEQ[REVERSE],'  ',SEQ[PLAIN],' ',SEQ[REVERSE],'  ',SEQ[PLAIN],
  '    ',SEQ[REVERSE],'  ',SEQ[PLAIN],'    ',SEQ[REVERSE],'  ',SEQ[PLAIN],'  ',
  SEQ[REVERSE],'  ',SEQ[PLAIN],'    ',SEQ[REVERSE],'  ',SEQ[PLAIN],'  ',
  SEQ[REVERSE],'  ',SEQ[PLAIN],' ',SEQ[REVERSE],'  ',SEQ[PLAIN],'  ',SEQ[REVERSE],
  '  ',SEQ[PLAIN],'     ',SEQ[REVERSE],'  ');

  CursorXY(x,y+5);
  WRITE(SEQ[REVERSE],'  ',SEQ[PLAIN],'  ',SEQ[REVERSE],'  ',SEQ[PLAIN],' ',
  SEQ[REVERSE],'  ',SEQ[PLAIN],'  ',SEQ[REVERSE],'  ',SEQ[PLAIN],' ',
  SEQ[REVERSE],'     ',SEQ[PLAIN],'  ',SEQ[REVERSE],'  ',SEQ[PLAIN],' ',
  SEQ[REVERSE],'  ',SEQ[PLAIN],'    '
  ,SEQ[REVERSE],'  ',SEQ[PLAIN],'    ',
  SEQ[REVERSE],'      ',SEQ[PLAIN],' ',SEQ[PLAIN] ,'  ',SEQ[PLAIN],' ',
  SEQ[REVERSE],'  ',SEQ[PLAIN],'  ',SEQ[REVERSE],'  ',SEQ[PLAIN],' ', SEQ[REVERSE],
  '  ',SEQ[PLAIN],'  ',SEQ[REVERSE],'  ',SEQ[PLAIN],' ',SEQ[REVERSE],'  ',SEQ[PLAIN],
  '  ',SEQ[REVERSE],'  ');

  CursorXY(x,y+6);
  WRITE(SEQ[PLAIN],' ',SEQ[REVERSE],'    ',SEQ[PLAIN],'   ',SEQ[REVERSE],'    ',
  SEQ[PLAIN],'  ',SEQ[REVERSE],'  ',SEQ[PLAIN],'  ',SEQ[REVERSE],'  ',SEQ[PLAIN],' ',
  SEQ[REVERSE],'  ',SEQ[PLAIN],' ',SEQ[REVERSE],'     ',SEQ[PLAIN],' ',SEQ[REVERSE],
  '     ',SEQ[PLAIN],' ',SEQ[REVERSE],'  ',SEQ[PLAIN],'  ',SEQ[REVERSE],'  ',
  SEQ[PLAIN],' ',SEQ[REVERSE],'  ',SEQ[PLAIN],' ',SEQ[REVERSE],'     ',SEQ[PLAIN],
  '  ',SEQ[REVERSE],'  ',SEQ[PLAIN],'  ',SEQ[REVERSE],'  ',SEQ[PLAIN],'  ',
  SEQ[REVERSE],'    ',SEQ[PLAIN]);

  WRITE(SEQ[CYAN]);
  CursorXY(x+1,y+0); WRITE('CP/M-80 & Turbo Modula-2 version (C) 2015');
  CursorXY(x+1,y+1); WRITE('Microsoft DOS 5.0 QBASIC version (C) 1991');
  Center(13,'Written by Francesco Sblendorio');
END IntroScreen;

PROCEDURE SelectionScreen();
VAR m:INTEGER;
    ch:CHAR;
BEGIN
  HideCursor();
  WRITE(SEQ[YELLOW]); Center(15,'Make your choice');
  m:=0;
  WRITE(SEQ[WHITE]);
  Center(17,'1. Start Game                 ');
  Center(18,'2. Set Preferences            ');
  Center(19,'3. About GORILLA.BAS          ');
  Center(20,'4. Exit to CP/M command prompt');
  WHILE (m<1) OR (m>4) DO
    ReadChar(ch);
    IF (ch>='1') AND (ch<='4') THEN
      m:=ORD(ch)-48
    ELSIF ch=15C THEN
      m:=1;
    ELSIF (ch=33C) OR (ch=3C) THEN
      m:=4;
    ELSE
      m:=0;
    END;
  END;
  choose:=m;
END SelectionScreen;

PROCEDURE Preferences();
VAR ch:CHAR;
CONST s='               ';
BEGIN
  Clear(15,20);
  HideCursor();
  WRITE(SEQ[YELLOW]); Center(15,'Preferences');
  WRITE(SEQ[WHITE]);
  CursorXY(26,17);
  WRITE('1. Player 1 name: ',SEQ[DARK],playerName1,SEQ[NODARK]);
  CursorXY(26,18);
  WRITE('2. Player 2 name: ',SEQ[DARK],playerName2,SEQ[NODARK]);
  CursorXY(26,19);
  WRITE('3. Total  points: ',SEQ[DARK],totalScore:0,SEQ[NODARK]);
  CursorXY(26,20);
  WRITE('4. Gravity m/s^2: ',SEQ[DARK],g:0:1,SEQ[NODARK]);
  CursorXY(26,21);
  WRITE('5. Back to main menu');
  LOOP
    ReadChar(ch);
    IF (ch='5') OR (ch=33C) OR (ch=3C) THEN
      choose:=-1; RETURN;
    ELSIF (ch='1') THEN
      CursorXY(44,17);
      WRITE(SEQ[DARK],SEQ[REVERSE],s);
      CursorXY(44,17); ShowCursor;
      READ(playerName1); HideCursor;
      IF playerName1='' THEN playerName1:='Player 1' END;
      CursorXY(44,17);
      WRITE(SEQ[PLAIN],SEQ[DARK],s);
      CursorXY(44,17);
      WRITE(playerName1,SEQ[NODARK]);
    ELSIF (ch='2') THEN
      CursorXY(44,18);
      WRITE(SEQ[DARK],SEQ[REVERSE],s);
      CursorXY(44,18); ShowCursor;
      READ(playerName2); HideCursor;
      IF playerName2='' THEN playerName2:='Player 2' END;
      CursorXY(44,18);
      WRITE(SEQ[PLAIN],SEQ[DARK],s);
      CursorXY(44,18);
      WRITE(playerName2,SEQ[NODARK]);
    ELSIF (ch='3') THEN
      CursorXY(44,19);
      WRITE(SEQ[DARK],SEQ[REVERSE],s);
      CursorXY(44,19); ShowCursor;
      READ(totalScore); HideCursor;
      IF totalScore=0 THEN totalScore:=3 END;
      CursorXY(44,19);
      WRITE(SEQ[PLAIN],SEQ[DARK],s);
      CursorXY(44,19);
      WRITE(totalScore:0,SEQ[NODARK]);
    ELSIF (ch='4') THEN
      CursorXY(44,20);
      WRITE(SEQ[DARK],SEQ[REVERSE],s);
      CursorXY(44,20); ShowCursor;
      READ(g); HideCursor;
      IF g=0.0 THEN g:=9.8 END;
      CursorXY(44,20);
      WRITE(SEQ[PLAIN],SEQ[DARK],s);
      CursorXY(44,20);
      WRITE(g:0:1,SEQ[NODARK]);
    END
  END;
  choose:=-1;
  ReadChar(ch);
END Preferences;

PROCEDURE InfoScreen();
VAR ch:CHAR;
BEGIN
  Clear(3,22);
  WRITE(SEQ[YELLOW],SEQ[REVERSE]);
  Center(4,'                           ');
  Center(5,'   G O R I L L A . B A S   ');
  Center(6,'                           ');
  WRITE(SEQ[CYAN],SEQ[PLAIN]);
  Center(8,'written by');
  Center(9,'Francesco Sblendorio');
  WRITE(SEQ[LIGHTBLUE],SEQ[UNDERLINE]);
  Center(10,'http://www.sblendorio.eu');
  WRITE(SEQ[NOUNDERLINE],SEQ[CYAN]);
  Center(12,
   'CP/M & Modula-2 version (C) 2015. Based on Microsoft QBASIC game');
  WRITE(SEQ[WHITE]);
  CursorXY(7,15); WRITE(
  'The game consists in two gorillas throwing explosive bananas at each');
  CursorXY(7,17); WRITE(
  'other above a city skyline. The players can adjust the angle and ve-');
  CursorXY(7,19); WRITE(
  'locity of each throw.');
  CursorXY(40,21); WRITE('(Wikipedia - ',SEQ[LIGHTBLUE],SEQ[UNDERLINE],
  'https://goo.gl/TtzH9S');
  WRITE(SEQ[WHITE],SEQ[NOUNDERLINE],SEQ[PLAIN],')');
  ReadChar(ch);
END InfoScreen;

PROCEDURE DoExit();
VAR ch:CHAR;
BEGIN
  Clear(15,20);
  WRITE(SEQ[WHITE]);
  Center(17,'Are you sure you want to exit?');
  Center(19,'(Y/N)');
  choose:=0;
  REPEAT
    ReadChar(ch);
    IF (ch='y') OR (ch='Y') OR (ch='1') THEN
      choose:=4
    ELSIF (ch='n') OR (ch='N') OR (ch='0') OR (ch=33C) OR (ch=3C) THEN
      choose:=-1
    END
  UNTIL choose#0;
END DoExit;

PROCEDURE ExitScreen();
BEGIN
  WRITE(SEQ[WHITE]);
  ResetTerm();
  ClrScr;
  ShowCursor();
END ExitScreen;

BEGIN
  AskTermType();
  RandomizeShuffle();

  choose:=1;
  REPEAT
    IF choose=-1 THEN Clear(16,21) ELSE IntroScreen END;
    SelectionScreen;
    CASE choose OF
      1: StartGame |
      2: Preferences |
      3: InfoScreen |
      4: DoExit
    END;
  UNTIL choose=4;
  ExitScreen;
END Main.
