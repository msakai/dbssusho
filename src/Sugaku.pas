unit Sugaku;

interface

function ArcCos(X: Extended): Extended;
function ArcSin(X: Extended): Extended;
function ArcTan2(Y, X: Extended): Extended;
function Cosh(X: Extended): Extended;
function Log2(X: Extended): Extended;
function Log10(X: Extended): Extended;
function Power(X, Y: Extended): Extended;
function Power2(X: Extended): Extended;
function Power10(X: Extended): Extended;
function Sinh(X: Extended): Extended;
function Tan(X: Extended): Extended;
function Tanh(X: Extended): Extended;

implementation


function ArcCos(X: Extended): Extended;
begin
    if X = 0 then
        Result := Pi / 2
    else
        Result := ArcTan(Sqrt(1 - Sqr(X) / X));
end;

function ArcSin(X: Extended): Extended;
begin
    if X = 1 then
        Result := Pi / 2
    else
        Result := ArcTan(X / Sqrt(1 - Sqr(X)));
end;

function ArcTan2(Y, X: Extended): Extended;
begin
    if X = 0 then
        Result := Pi / 2
    else
        Result := ArcTan(Y / X);

    if (X <= 0) and (Y < 0) then
        Result := Result - Pi
    else if (X < 0) and (Y >= 0) then
        Result := Result + Pi;
end;

function Cosh(X: Extended): Extended;
begin
    Result := (Exp(X) + Exp(-X)) / 2;
end;

function Log2(X: Extended): Extended;
begin
    Result := Ln(X) / Ln(2);
end;

function Log10(X: Extended): Extended;
begin
    Result := Ln(x) / Ln(10);
end;

function Power(X, Y: Extended): Extended;
begin
    Result := Exp(Y * Ln(X));
end;

function Power2(X: Extended): Extended;
begin
    Result := Exp(2 * Ln(X));
end;

function Power10(X: Extended): Extended;
begin
    Result := Exp(10 * Ln(X));
end;

function Sinh(X: Extended): Extended;
begin
    Result := (Exp(X) - Exp(-X)) / 2;
end;

function Tan(X: Extended): Extended;
begin
    Result := Sin(X) / Cos(X);
end;

function Tanh(X: Extended): Extended;
begin
    Result := (Exp(X) - Exp(-X)) / (Exp(X) + Exp(-X));
end;

end.
