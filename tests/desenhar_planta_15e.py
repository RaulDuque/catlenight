"""Uso: python tests/desenhar_planta_15e.py contornos.json (Python + Pillow)."""
import json
import sys
from pathlib import Path

from PIL import Image, ImageDraw, ImageFont

ROOT = Path(__file__).resolve().parents[1]
EVIDENCIAS = ROOT / 'MD-usario/relatorios/evidencias'
ESTUDO = ROOT / 'assets-exemple-2d/estudo-local'
ESTUDO.mkdir(exist_ok=True)
(ESTUDO / '.gdignore').touch()
contornos = json.loads(Path(sys.argv[1]).read_text())
NAVY, TEAL, GOLD, WHITE = '#152339', '#007c78', '#a95d13', '#ffffff'


def fonte(size):
    for family in ('DejaVuSans.ttf', 'arial.ttf'):
        try:
            return ImageFont.truetype(family, size)
        except OSError:
            continue
    return ImageFont.load_default()


def titulo(draw, xy, label, size=20, cor=NAVY):
    draw.text(xy, label, font=fonte(size), fill=cor)


def planta():
    im = Image.new('RGB', (1490, 1010), '#f7f8fa')
    d = ImageDraw.Draw(im)
    titulo(d, (44, 18), 'Catlenight   /   Planta estrutural do prólogo', 33)
    titulo(d, (46, 68), '15-E   •   Corte lateral em Z = 0   •   Contornos das colisões em execução', 19)
    def xy(x,y):
        return (75+(x+47)*25, 890-y*25)
    for y in range(0,31,5):
        a,b = xy(-47,y), xy(4.5,y)
        d.line([a,b],fill='#dce1e6')
        titulo(d,(12,a[1]-10),f'{y} m',14)
    for nome, pontos in contornos.items():
        cor = GOLD if nome.startswith(('Lance','Rampa','Soleira')) else TEAL
        d.polygon([xy(*p) for p in pontos],fill=cor)
    for x,y,t in [(-42,26.1,'Galeria   •   27,08 × 6,15 m livres'),(-37,18.7,'Descanso  2,46 m'),
                  (-42,12.5,'Salão e trono'),(-34,10.7,'↑ Acesso provisório'),(-15,6.3,'Escadaria exterior'),
                  (-15,5.1,'9,85 × 9,85 m'),(-37,21.5,'Avanço  3,08 m'),(-26.4,18.6,'Avanço  3,69 m')]:
        titulo(d,xy(x,y),t,16)
    for x,y in [((1040-1552)/26,8),((1040-1552)/26,400/26)]:
        a,b=xy(x,y)
        d.ellipse((a-5,b-5,a+5,b+5),fill='#9d477c')
    titulo(d,(46,944),'Largura total  50,46 m      |      Galeria a 22,15 m sobre o nascimento      |      Escadas a 45°',18)
    a,b=xy(-2,2),xy(3,2)
    d.line([a,b],fill=NAVY,width=3)
    for i in range(6):
        x,y=xy(i-2,2)
        d.line((x,y-4,x,y+5),fill=NAVY,width=2)
    titulo(d,(a[0],a[1]-28),'5 metros',16)
    im.save(EVIDENCIAS/'15e-planta-em-escala.png')


def comparar():
    origem=Image.open(ROOT/'assets-exemple-2d/Final Stage - _Bloodlines_.png').convert('RGB')
    # Os painéis têm origens Y independentes e compartilham a mesma escala XY.
    paineis=[
        ('Exterior e salão', (350,510,1658,954),0,
         'ParedeExterior PatamarInferior LanceExterior PatamarSuperior Soleira PisoSalao Estrado RampaDoEstrado ParedeDoTrono TetoSalaoEsquerdo TetoSalaoDireito PatamarDaEscada',
         [(1264,672),(1520,928)], 'Extremos (1264,672) e (1520,928). Em rosa, os dois pontos usados na 15-D.'),
        ('Escada interna', (612,259,1144,504),48,
         'PatamarDaEscada ParedeEscada LanceInferior Descanso LanceSuperior ChegadaGaleria PisoGaleriaDireito',
         [(976,480),(880,384),(816,384),(736,304)], 'Da direita para a esquerda: 96 × 96 px, descanso de 64 px, 80 × 80 px. Piso inferior sobre o vão de ligação.'),
        ('Galeria', (355,8,1146,247),128,
         'PisoGaleriaEsquerdo PisoGaleriaDireito ChegadaGaleria ParedeGaleriaEsquerda ParedeGaleriaDireita TetoGaleria',
         [(400,224),(1104,224),(400,64),(800,224)], 'Paredes internas x = 400 e 1104. Piso y = 224, teto y = 64. Rosa: y = 35 dentro da pedra.')]
    canvas=Image.new('RGB',(2660,2250),'#122033')
    out=ImageDraw.Draw(canvas)
    offset=20
    for nome,box,dy,lista,marcas,legenda in paineis:
        crop=origem.crop(box).resize(((box[2]-box[0])*2,(box[3]-box[1])*2),Image.Resampling.NEAREST)
        d=ImageDraw.Draw(crop)
        def xy(u,v):
            return (round(2*(u-box[0])),round(2*(v-box[1])))
        for nome_corpo in lista.split():
            pontos=[xy(x*26+1552,928-y*26-dy) for x,y in contornos[nome_corpo]]
            d.line(pontos+[pontos[0]],fill='#44e9ed',width=2)
        antigas=[(1412,804),(1516,892)] if dy==0 else ([(450,35)] if dy==128 else [])
        for u,v in marcas+antigas:
            x,y=xy(u,v)
            c='#ff75c4' if (u,v) in antigas else '#ffe261'
            d.ellipse((x-6,y-6,x+6,y+6),outline=c,width=3)
        titulo(out,(20,offset),nome,28,WHITE)
        titulo(out,(max(320,len(nome)*20),offset+6),legenda,20,WHITE)
        canvas.paste(crop,(20,offset+44))
        offset+=64+crop.height
    canvas.crop((0,0,2660,offset)).save(ESTUDO/'15e-sobreposicao.png')


planta()
comparar()
