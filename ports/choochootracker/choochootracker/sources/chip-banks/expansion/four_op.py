"""Bounded data-only TFI and VOPM text import; original chip-specific starter recipes.
No player code or third-party instrument data is included. Recipes are MIT licensed.
"""
import hashlib,json,re,subprocess

def validate(chip,base,ops):
 if chip not in (25,26) or len(base)!=15 or len(ops)!=4:raise ValueError('four-op layout')
 limits=[1,7,7,3,3,7,1,7 if chip==25 else 255,3,127,127,15,100,65535,65535]
 if base[0]!=1 or not 1<=base[3]<=3 or any(not (-100 if i==12 else 0)<=v<=limits[i] for i,v in enumerate(base)):raise ValueError('four-op global range')
 if chip==25 and any(base[8:11]):raise ValueError('OPM LFO fields in Genesis patch')
 for op in ops:
  if len(op)!=12 or any(not 0<=v<=hi for v,hi in zip(op,[15,7,127,3,31,31,31,15,15,15,3,1])):raise ValueError('four-op operator range')
  if (chip==25 and op[10]) or (chip==26 and op[9]):raise ValueError('incompatible chip operator')
 return base,ops

def parse_tfi(data):
 if len(data)!=42:raise ValueError('TFI requires exactly 42 bytes')
 base=[1,data[0],data[1],3,0,0,0,0,0,0,0,15,0,0,0];ops=[]
 for index in (0,2,1,3): # TFI hardware order S1,S3,S2,S4 -> algorithm order
  op=list(data[2+10*index:12+10*index]);dt=op[1]
  if dt>6:raise ValueError('TFI detune out of range')
  op[1]=dt-3 if dt>=3 else 7-dt
  ops.append(op+[0,0])
 return validate(25,base,ops)

def parse_opm(data):
 if len(data)>1024*1024:raise ValueError('OPM file too large')
 text=data.decode('utf-8-sig');records=[];current=None;ids=set()
 for line in text.splitlines():
  if 'MiOPMdrv sound bank Paramer Ver' in line and 'Ver2002.04.22' not in line:raise ValueError('unsupported OPM version')
 for raw in text.splitlines():
  if len(raw)>1024:raise ValueError('OPM line too long')
  line=raw.split('//',1)[0].split(';',1)[0].strip()
  if not line:continue
  if line.startswith('@:'):
   match=re.fullmatch(r'@:\s*(\d+)\s+(.+)',line)
   if not match:raise ValueError('OPM entry header')
   number=int(match[1]);name=match[2].strip()
   if number>65535 or number in ids or len(name.encode())>63 or any(ord(c)<32 for c in name) or len(records)>=4096:raise ValueError('OPM entry identity')
   ids.add(number);current={'name':name,'program':number,'fields':{}};records.append(current);continue
  if current is None or ':' not in line:raise ValueError('OPM field outside entry')
  key,values=line.split(':',1);key=key.strip()
  bounds={'LFO':[255,127,127,3,31],'CH':[127,7,7,3,7,120,128],**{k:[31,31,31,15,15,127,3,15,7,3,128] for k in ('M1','C1','M2','C2')}}
  if key not in bounds or key in current['fields']:raise ValueError('unsupported or duplicate OPM field '+key)
  if not re.fullmatch(r'\s*\d+(?:\s+\d+)*\s*',values):raise ValueError('OPM number syntax')
  v=list(map(int,values.split()))
  if len(v)!=len(bounds[key]) or any(x>hi for x,hi in zip(v,bounds[key])):raise ValueError('OPM range')
  current['fields'][key]=v
 result=[]
 for entry in records:
  f=entry['fields']
  if set(f)!=set(('LFO','CH','M1','C1','M2','C2')):raise ValueError('incomplete OPM entry')
  pan,fb,alg,ams,pms,mask,noise=f['CH'];lfrq,amd,pmd,wave,nfrq=f['LFO']
  # VOPM PAN is its MIDI CC position 0..127 (64 center), not a hardware bitmask.
  # Arbitrary balance has no exact native chip representation; reject it.
  if pan not in (0,64,127):raise ValueError('OPM partial pan is unsupported (use 0/64/127)')
  if noise or nfrq or mask&7:raise ValueError('OPM noise or invalid operator mask is unsupported')
  base=[1,alg,fb,{0:1,64:3,127:2}[pan],ams,pms,1,lfrq,wave,amd,pmd,mask>>3,0,0,entry['program']]
  ops=[]
  for key in ('M1','C1','M2','C2'):
   ar,dr,sr,rr,sl,tl,ks,mul,dt,dt2,am=f[key]
   if am not in (0,128):raise ValueError('OPM AM enable must be 0 or 128')
   am>>=7;ops.append([mul,dt,tl,ks,ar,dr,sr,rr,sl,0,dt2,am])
  validate(26,base,ops);result.append({'name':entry['name'],'base':base,'ops':ops})
 if not result:raise ValueError('empty OPM bank')
 return result

SHAPES={'key':(31,11,3,7,5),'pluck':(31,17,8,9,7),'bell':(31,8,3,5,5),'held':(31,0,0,9,0),'pad':(12,5,0,5,2),'brass':(20,10,0,8,3),'hit':(31,24,19,12,10)}
def op(mul,tl,shape,dt=0):
 ar,dr,sr,rr,sl=SHAPES[shape];return [mul,dt,tl,1,ar,dr,sr,rr,sl,0,0,0]
# Individually authored envelopes, routing and ratios; paired chip voicings,
# not claimed to reproduce game/arcade ROM patches. Categories are design intent.
RECIPES=[
 ('Twin Reed','Keys',4,0,[(1,30,'key'),(1,8,'key'),(3,40,'key'),(1,12,'key')]),
 ('Felt Pluck','Keys',0,2,[(5,54,'hit'),(3,45,'pluck'),(2,31,'key'),(1,4,'pluck')]),
 ('Wire Clav','Keys',4,5,[(2,20,'hit'),(1,8,'pluck'),(7,44,'hit'),(2,17,'pluck')]),
 ('Copper Tines','Electric Piano',4,0,[(11,24,'hit'),(1,6,'bell'),(1,38,'key'),(1,12,'bell',1)]),
 ('Soft Reed EP','Electric Piano',0,1,[(4,64,'hit'),(3,53,'key'),(1,33,'key'),(1,2,'bell')]),
 ('Hollow EP','Electric Piano',5,1,[(2,36,'pluck'),(1,10,'bell'),(2,25,'bell'),(1,17,'key',5)]),
 ('Round Sub','Bass',0,3,[(3,64,'hit'),(2,50,'pluck'),(1,35,'key'),(0,2,'key')]),
 ('Pick Bass','Bass',4,2,[(3,26,'hit'),(0,8,'pluck'),(2,43,'hit'),(1,17,'key')]),
 ('Rubber Root','Bass',0,6,[(7,66,'hit'),(3,56,'key'),(1,18,'pluck'),(1,5,'held')]),
 ('Copper Solo','Lead',0,5,[(5,59,'held'),(3,43,'held'),(1,31,'brass'),(1,7,'held')]),
 ('Hollow Square','Lead',4,7,[(2,23,'held'),(1,12,'held'),(4,51,'held'),(2,28,'held')]),
 ('Thin Whistle','Lead',4,0,[(2,69,'brass'),(1,8,'held'),(3,81,'held'),(2,37,'held')]),
 ('Cloud Pair','Pad',4,0,[(3,58,'pad'),(1,13,'pad',1),(2,53,'pad'),(1,16,'pad',5)]),
 ('Fifth Mist','Pad',7,0,[(1,16,'pad'),(3,29,'pad'),(2,24,'pad',1),(4,34,'pad',5)]),
 ('Slow Glass','Pad',4,2,[(7,37,'pad'),(1,17,'pad'),(5,48,'pad'),(2,26,'pad')]),
 ('Bronze Bell','Bell-Mallet',4,0,[(7,23,'bell'),(1,9,'bell'),(11,39,'pluck'),(2,17,'bell')]),
 ('Wood Bars','Bell-Mallet',4,1,[(4,27,'hit'),(1,8,'pluck'),(7,53,'hit'),(1,23,'pluck')]),
 ('Ice Chime','Bell-Mallet',0,0,[(13,44,'pluck'),(7,55,'bell'),(3,27,'bell'),(1,5,'bell')]),
 ('Small Pipes','Organ',7,0,[(0,14,'held'),(1,10,'held'),(2,25,'held'),(3,29,'held')]),
 ('Reed Combo','Organ',5,3,[(2,39,'held'),(1,12,'held'),(2,28,'held'),(4,35,'held')]),
 ('Horn Pair','Brass-Wind',4,5,[(1,26,'brass'),(1,12,'brass'),(2,41,'brass'),(1,18,'brass',1)]),
 ('Low Tom','Percussion',4,1,[(2,38,'hit'),(0,7,'pluck'),(5,68,'hit'),(1,33,'hit')]),
 ('Metal Click','Percussion',0,7,[(15,17,'hit'),(11,25,'hit'),(7,24,'hit'),(2,14,'hit')]),
 ('Relay Storm','FX',0,7,[(13,17,'held'),(7,24,'held'),(5,27,'held'),(1,18,'held')]),
]
def originals(chip):
 result=[]
 for number,(name,category,alg,fb,operators) in enumerate(RECIPES):
  base=[1,alg,fb,3,0,0,0,0,0,0,0,15,0,200 if chip==25 else 201,number];ops=[op(*o) for o in operators]
  validate(chip,base,ops);result.append(dict(name=name,category=category,base=base,ops=ops))
 return result

def write_patch(output,writer,chip,entry,filename):
 base,ops=validate(chip,entry['base'],entry['ops']);ir=output/(filename+'.chip')
 ir.write_text(f'CHOOCHOO-OPL-IR 1 {chip}\n- FourOp base: '+','.join(map(str,base))+'\n- FourOp name: '+entry['name']+'\n'+''.join(f'- FourOp op{i}: '+','.join(map(str,o))+'\n' for i,o in enumerate(ops))+'# END\n')
 subprocess.run([str(writer),str(ir),str(output/(filename+'.cni'))],check=True,stdout=subprocess.DEVNULL);ir.unlink()

def convert_originals(output,writer):
 records=[]
 for chip in (25,26):
  for e in originals(chip):
   uid=hashlib.sha256(json.dumps([chip,e['base'][:13],e['ops']],separators=(',',':')).encode()).hexdigest();filename='four-op-'+str(chip)+'-'+uid[:24];write_patch(output,writer,chip,e,filename)
   records.append(dict(type=chip,bank_id=e['base'][13],bank='ChooChoo Genesis' if chip==25 else 'ChooChoo Arcade',category=e['category'],name=e['name'],path=filename+'.cni',uid=uid,source_program=e['base'][14],license='MIT',origin='tools/chip_banks/four_op.py original recipes',human_listened=False))
 return records
