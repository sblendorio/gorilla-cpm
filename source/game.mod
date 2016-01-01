IMPLEMENTATION MODULE Game;
FROM XTerm IMPORT TERMTYPE,ESCAPE,GetTermType,ResetTerm,SEQ,AskTermType,
                  ClrScr,PlotBox,Center,HideCursor,ShowCursor,CursorXY,
                  ClrEol,RandomizeShuffle,STRINGSEQ,InputCardinal;
FROM Terminal IMPORT ReadChar;
FROM MathLib IMPORT Sin,Cos,Entier,Random;
FROM Convert IMPORT StrToCard;
FROM Strings IMPORT Length;

TYPE OUTCOME=(NOTHING,BUILDING,PLAYER);
VAR t:TERMTYPE;
    s:ARRAY [0..79] OF CHAR;
    screen:ARRAY [1..79] OF ARRAY [1..24] OF CHAR;
    widths:ARRAY [0..9] OF CARDINAL;
    heights:ARRAY [0..9] OF CARDINAL;
    colors:ARRAY [0..9] OF STRINGSEQ;
    outcome,dummy:OUTCOME;

PROCEDURE ClearBrick(x,y:CARDINAL;ch:CHAR;simulation:BOOLEAN);
BEGIN
  IF (x>0) AND (x<80) AND (y>0) AND (y<25) THEN
    IF (screen[x][y]=1C) THEN
      CursorXY(x,y); WRITE(ch);
      IF NOT simulation THEN screen[x][y]:=0C END;
    END;
  END;
END ClearBrick;

PROCEDURE HitBuilding(x,y:CARDINAL;simulation:BOOLEAN);
VAR ch:CHAR;
    i:CARDINAL;
BEGIN
  IF simulation THEN ch:='.'; WRITE(SEQ[WHITE]); ELSE ch:=' ' END;
  ClearBrick(x,y-1,ch,simulation);
  FOR i:=x-1 TO x+1 DO ClearBrick(i,y,ch,simulation) END;
  ClearBrick(x,y+1,ch,simulation);
END HitBuilding;

PROCEDURE IsInnerBuildingHit(x,y:CARDINAL):BOOLEAN;
BEGIN
  IF (x>1) AND (x<79) THEN
    RETURN (screen[x-1][y]=1C) AND (screen[x+1][y]=1C);
  ELSIF (x=1) THEN
    RETURN (screen[2][y]=1C);
  ELSE
    RETURN (screen[78][y]=1C);
  END;
END IsInnerBuildingHit;

PROCEDURE LookUpstairs(VAR x,y:CARDINAL):OUTCOME;
BEGIN
  WHILE (y>1) AND (screen[x][y]=1C) DO
    DEC(y);
  END;
  IF screen[x][y]=2C THEN
    RETURN PLAYER;
  ELSE
    INC(y);
    RETURN BUILDING;
  END;
END LookUpstairs;

PROCEDURE TraceBullet(j,i,y0:CARDINAL;a,b:REAL;ch:CHAR;
                      VAR finalX,finalY:CARDINAL):OUTCOME;
VAR x,y:REAL;
    yInt:CARDINAL;
    result:OUTCOME;
BEGIN
  result:=NOTHING;
  x:=FLOAT(j-1)/2.0;
  y:=FLOAT(y0)+(a*x*x)-(b*x);
  IF (y>=1000.0) THEN
    yInt:=1000;
  ELSE
    yInt:=Entier(y);
  END;
  IF (yInt>=1) AND (yInt<25) THEN
    IF screen[i][yInt]=2C THEN
      result:=PLAYER;
    ELSIF screen[i][yInt]=1C THEN
      IF IsInnerBuildingHit(i,yInt) THEN
        result:=LookUpstairs(i,yInt);
      ELSE
        result:=BUILDING
      END
    ELSE
      CursorXY(i,yInt); WRITE(ch);
    END
  END;
  finalX:=i;
  finalY:=yInt;
  RETURN result;
END TraceBullet;

PROCEDURE Shoot(y0:CARDINAL;theta,v0:REAL;
                xSTART,xEND:CARDINAL;ch:CHAR;
                VAR finalX,finalY:CARDINAL):OUTCOME;
VAR i,j:CARDINAL;
    x,y:REAL;
    outcome:OUTCOME;
VAR a,b:REAL;
BEGIN
  IF v0=0.0 THEN v0:=1.0 END;
  outcome:=NOTHING;
  v0:=v0/5.0;
  a:=g/(2.0*v0*v0*Cos(theta)*Cos(theta));
  b:=Sin(theta)/Cos(theta);
  IF (xSTART<xEND) THEN
    j:=1;
    i:=xSTART;
    WHILE (i<=xEND) AND (outcome=NOTHING) DO
      outcome:=TraceBullet(j,i,y0,a,b,ch,finalX,finalY);
      INC(j);
      INC(i);
    END;
  ELSE
    j:=1;
    i:=xSTART;
    WHILE (i>=xEND) AND (outcome=NOTHING) DO
      outcome:=TraceBullet(j,i,y0,a,b,ch,finalX,finalY);
      INC(j);
      DEC(i);
    END;
  END;
  RETURN outcome;
END Shoot;

PROCEDURE Deg2Rad(deg:INTEGER):REAL;
CONST pi=3.14159265;
BEGIN
  RETURN (pi/180.0)*FLOAT(deg);
END Deg2Rad;

PROCEDURE ArmUpLeft(x,y:INTEGER);
BEGIN
  CursorXY(x-1,y-2); WRITE('\');
  CursorXY(x-1,y-1); WRITE(' ');
END ArmUpLeft;

PROCEDURE ArmDownLeft(x,y:INTEGER);
BEGIN
  CursorXY(x-1,y-2); WRITE(' ');
  CursorXY(x-1,y-1); WRITE('-');
END ArmDownLeft;


PROCEDURE ArmUpRight(x,y:INTEGER);
BEGIN
  CursorXY(x+1,y-2); WRITE('/');
  CursorXY(x+1,y-1); WRITE(' ');
END ArmUpRight;

PROCEDURE ArmDownRight(x,y:INTEGER);
BEGIN
  CursorXY(x+1,y-2); WRITE(' ');
  CursorXY(x+1,y-1); WRITE('-');
END ArmDownRight;

PROCEDURE DrawPlayer(x,y:INTEGER);
VAR i,j:INTEGER;
BEGIN
  WRITE(SEQ[WHITE]);
  CursorXY(x-1,y-2); WRITE(' o ');
  CursorXY(x-1,y-1); WRITE('-|-');
  CursorXY(x-1,y-0); WRITE('/ \');
  screen[x][y-2]:=2C;
  FOR i:=x-1 TO x+1 DO
    FOR j:=y-1 TO y DO
      screen[i][j]:=2C
    END
  END
END DrawPlayer;

PROCEDURE KillPlayer(x,y:INTEGER);
VAR i,j:INTEGER;
BEGIN
  WRITE(SEQ[WHITE],SEQ[BLINK]);
  CursorXY(x-2,y-2); WRITE('-\|/-');
  CursorXY(x-2,y-1); WRITE('-*X*-');
  CursorXY(x-2,y-0); WRITE('-/|\-');
  WRITE(SEQ[NOBLINK]);
END KillPlayer;

PROCEDURE WinnerPlayer(x,y:INTEGER);
VAR i,j:INTEGER;
BEGIN
  WRITE(SEQ[WHITE]);
  CursorXY(x-1,y-2); WRITE('\o/');
  CursorXY(x-1,y-1); WRITE(' | ');
  CursorXY(x-1,y-0); WRITE('/ \');
END WinnerPlayer;

PROCEDURE DrawBuilding(VAR color:STRINGSEQ;x,h,w:CARDINAL);
VAR i,j,count:CARDINAL;
    line:ARRAY [0..15] OF CHAR;
BEGIN
  WRITE(color);
  line:='               ';
  line[w]:=0C;
  IF (h=0) OR (w=0) THEN RETURN END;
  count:=0;
  FOR i:=25-h TO 24 DO
    INC(count);
    CursorXY(x,i);
    IF (i=24) OR (i=25-h) OR (count MOD 2=1) THEN
      WRITE(SEQ[REVERSE],line);
    ELSE
      FOR j:=1 TO w DO
        screen[x+j-1,i]:=1C;
        IF (i<24) AND (count MOD 2=0) THEN
          IF (j=w) OR (j MOD 2=1) THEN
            WRITE(SEQ[REVERSE],' ');
          ELSE
            WRITE(SEQ[PLAIN],' ');
          END;
        END;
      END;
    END
  END;
  WRITE(SEQ[PLAIN],SEQ[NODARK],SEQ[WHITE]);
END DrawBuilding;

PROCEDURE InitBuildingDimensions(VAR widths,heights:ARRAY OF CARDINAL);
VAR i,j,t:CARDINAL;
    ts:STRINGSEQ;
BEGIN
  widths[0]:=7;
  widths[1]:=9;
  widths[2]:=5;
  widths[3]:=7;
  widths[4]:=7;
  widths[5]:=5;
  widths[6]:=7;
  widths[7]:=9;
  widths[8]:=7;
  widths[9]:=7;
  IF (GetTermType()=KAYPRO) OR (GetTermType()=ADM31) THEN
    FOR i:=0 TO 4 DO colors[i]:=SEQ[NODARK]; END;
    FOR i:=5 TO 8 DO colors[i]:=SEQ[DARK]; END;
  ELSE
    colors[0]:=SEQ[DARKCYAN];
    colors[1]:=SEQ[LIGHTGREY];
    colors[2]:=SEQ[RED];
    colors[3]:=SEQ[GREEN];
    colors[4]:=SEQ[DARKCYAN];
    colors[5]:=SEQ[LIGHTGREY];
    colors[6]:=SEQ[RED];
    colors[7]:=SEQ[GREEN];
    colors[8]:=SEQ[DARKCYAN];
    colors[9]:=SEQ[LIGHTGREY];
  END;
  FOR i:=0 TO 9 DO
    j:=Entier(Random()*10.0);
    t:=widths[i];
    widths[i]:=widths[j];
    widths[j]:=t;
    j:=Entier(Random()*10.0);
    ts:=colors[i];
    colors[i]:=colors[j];
    colors[j]:=ts;
    heights[i]:=Entier(Random()*15.0)+5;
  END;
  FOR i:=1 TO 79 DO
    FOR j:=1 TO 24 DO
      screen[i][j]:=0C
    END
  END
END InitBuildingDimensions;

PROCEDURE DrawBuildings(VAR widths,heights:ARRAY OF CARDINAL);
VAR i,x,h:CARDINAL;
BEGIN
  x:=1;
  FOR i:=0 TO 9 DO
    DrawBuilding(colors[i],x,heights[i],widths[i]);
    x:=x+widths[i]+1;
  END;
END DrawBuildings;

PROCEDURE SetInitialPlayersPosition(VAR x1,y1,x2,y2:CARDINAL;
                                    VAR widths,heights:ARRAY OF CARDINAL);
VAR b,i,space:CARDINAL;
BEGIN
  b:=Entier(Random()*3.0);
  space:=0;
  FOR i:=0 TO b DO
    space:=space+widths[i]+1;
  END;
  x1:=space-1-(widths[b] DIV 2);
  y1:=24-heights[b];

  b:=Entier(Random()*3.0);
  space:=0;
  FOR i:=9 TO (9-b) BY -1 DO
    space:=space+widths[i]+1;
  END;
  x2:=80-(space-1-(widths[9-b] DIV 2));
  y2:=24-heights[9-b];
END SetInitialPlayersPosition;

PROCEDURE PrintOutcome(o:OUTCOME);
BEGIN
  CASE o OF
    NOTHING: WRITE('NOTHING') |
    BUILDING: WRITE('BUILDING') |
    PLAYER: WRITE('PLAYER')
  END;
END PrintOutcome;

PROCEDURE ShowScore(s1,s2:CARDINAL);
BEGIN
  CursorXY(35,24); WRITE(SEQ[WHITE],' ',s1:0,'>Score<',s2:0,' ');
  CursorXY(35,23);
END ShowScore;

PROCEDURE Celebrate(VAR name:ARRAY OF CHAR);
VAR ch:CHAR;
BEGIN
  CursorXY(20,1);
  WRITE(SEQ[WHITE],SEQ[REVERSE],' ',name,' ',SEQ[PLAIN],
    ' won this battle! Press any key ');
  ReadChar(ch);
END Celebrate;

PROCEDURE StartGame();
VAR angle1:CARDINAL;
    speed1:CARDINAL;
    angle2:CARDINAL;
    speed2:CARDINAL;
    ch:CHAR;
    posName2:CARDINAL;
    x1,y1,x2,y2,finalX,finalY:CARDINAL;
    score1,score2:CARDINAL;
    winner:INTEGER;
BEGIN
  score1:=0; score2:=0;
  winner:=0;
  posName2:=80-Length(playerName2);
  REPEAT (* The war begins *)
    ClrScr;
    WRITE(SEQ[WHITE]);
    finalX:=0; finalY:=0;
    InitBuildingDimensions(widths,heights);
    DrawBuildings(widths,heights);
    SetInitialPlayersPosition(x1,y1,x2,y2,widths,heights);
    DrawPlayer(x1,y1);
    DrawPlayer(x2,y2);
    ShowScore(score1,score2);
    LOOP (* Single battle *)
      IF winner#2 THEN
        ShowCursor;
        CursorXY(1,1); WRITE(SEQ[DARK],playerName1,SEQ[NODARK]);
        CursorXY(1,2); WRITE("Angle:");
        IF NOT InputCardinal(8,2,angle1,3) THEN RETURN END;
        CursorXY(1,3); WRITE("Speed:");
        IF NOT InputCardinal(8,3,speed1,4) THEN RETURN END;
        HideCursor;
        CursorXY(1,1); ClrEol;
        CursorXY(1,2); ClrEol;
        CursorXY(1,3); ClrEol;
        IF (finalX#0) AND (finalY#0) THEN
          ArmDownRight(x2,y2);
          dummy:=Shoot(y2-2,Deg2Rad(angle2),
                       FLOAT(speed2),x2-1,1,' ',finalX,finalY);
          HitBuilding(finalX,finalY,FALSE);
        END;
        ArmUpLeft(x1,y1);
        outcome:=Shoot(y1-2,Deg2Rad(angle1),
                       FLOAT(speed1),x1+1,79,'*',finalX,finalY);
        IF outcome=PLAYER THEN
          winner:=1; finalX:=0; finalY:=0;
          INC(score1);
          KillPlayer(x2,y2);
          WinnerPlayer(x1,y1);
          ShowScore(score1,score2);
          Celebrate(playerName1);
          EXIT;
        END;
        IF outcome=BUILDING THEN
          HitBuilding(finalX,finalY,TRUE);
        END;
        IF finalY>20 THEN ShowScore(score1,score2) END;
      END;

      ShowCursor;
      CursorXY(posName2,1); WRITE(SEQ[DARK],playerName2,SEQ[NODARK]);
      CursorXY(69,2); WRITE("Angle:    ");
      IF NOT InputCardinal(76,2,angle2,3) THEN RETURN END;
      CursorXY(69,3); WRITE("Speed:     ");
      IF NOT InputCardinal(76,3,speed2,4) THEN RETURN END;
      HideCursor;
      CursorXY(1,1); ClrEol;
      CursorXY(1,2); ClrEol;
      CursorXY(1,3); ClrEol;
      ArmDownLeft(x1,y1);
      dummy:=Shoot(y1-2,Deg2Rad(angle1),
                   FLOAT(speed1),x1+1,79,' ',finalX,finalY);
      HitBuilding(finalX,finalY,FALSE);
      angle2:=angle2;
      ArmUpRight(x2,y2);
      outcome:=Shoot(y2-2,Deg2Rad(angle2),
                     FLOAT(speed2),x2-1,1,'*',finalX,finalY);
      IF outcome=PLAYER THEN
        winner:=2; finalX:=0; finalY:=0;
        INC(score2);
        KillPlayer(x1,y1);
        WinnerPlayer(x2,y2);
        ShowScore(score1,score2);
        Celebrate(playerName2);
        EXIT;
      END;
      IF outcome=BUILDING THEN
        HitBuilding(finalX,finalY,TRUE);
      END;
      IF finalY>20 THEN ShowScore(score1,score2) END;

      winner:=0;
    END;
  UNTIL score1+score2>=totalScore;

  ClrScr;
  WRITE(SEQ[RED]);
  PlotBox(2,2,79,23,TRUE,TRUE);
  WRITE(SEQ[YELLOW]); Center(7,'GAME OVER!');
  WRITE(SEQ[CYAN]); Center(9,'Score:');
  CursorXY(30,11); WRITE(SEQ[WHITE],playerName1);
  CursorXY(50,11); WRITE(SEQ[GREEN],score1:0);
  CursorXY(30,12); WRITE(SEQ[WHITE],playerName2);
  CursorXY(50,12); WRITE(SEQ[GREEN],score2:0);
  WRITE(SEQ[WHITE]); Center(15, 'Press any key...');
  ReadChar(ch);
  ClrScr;
END StartGame;

BEGIN
  g:=9.8;
  totalScore:=3;
  playerName1:='Player 1'; playerName2:='Player 2';
END Game.
