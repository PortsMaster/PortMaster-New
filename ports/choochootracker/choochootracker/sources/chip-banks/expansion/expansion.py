"""Pinned data-only factory expansion; unsupported source features are reported.

WOPN v2 layout and register order verified against libOPNMIDI's wopn_file.c,
opnmidi_cvt.hpp and opnmidi_opn2.cpp. No synthesizer code is imported.
"""
import hashlib, json, re, struct, subprocess, shutil
from pathlib import Path
from four_op import validate, parse_opm, write_patch

ROOT = Path(__file__).resolve().parents[2]

def parse_wopn(data):
    if len(data)>4*1024*1024 or len(data)<18 or data[:11]!=b'WOPN2-B2NK\0' or struct.unpack_from('<H',data,11)[0]!=2:
        raise ValueError('expected WOPN version 2')
    melodic,percussion=struct.unpack_from('>HH',data,13)
    count=melodic+percussion
    if not count or count>256 or len(data)!=18+count*(34+128*69) or data[17]&~15:
        raise ValueError('WOPN length, bank count or unsupported chip flags')
    result=[];excluded=[];offset=18+count*34
    for bank in range(count):
        for program in range(128):
            r=data[offset:offset+69];offset+=69
            identity=dict(bank=bank,program=program)
            if not any(r[37:65]):excluded.append(dict(identity,reason='blank'));continue
            note_offset=struct.unpack_from('>h',r,32)[0]
            if bank>=melodic or note_offset:
                excluded.append(dict(identity,reason='fixed percussion key' if bank>=melodic else 'note offset',note_offset=note_offset,percussion_key=r[34]));continue
            if r[35]&~63 or r[36]&~55:raise ValueError('reserved WOPN channel bits')
            base=[1,r[35]&7,(r[35]>>3)&7,3,(r[36]>>4)&3,r[36]&7,(data[17]>>3)&1,data[17]&7,0,0,0,15,0,210,program]
            ops=[]
            for index in (0,2,1,3): # Source register order -> algorithm order.
                mul,tl,ar,dr,sr,sl,ssg=r[37+index*7:44+index*7]
                if mul&128 or tl&128 or ar&32 or dr&96 or sr&224 or ssg&240:raise ValueError('reserved WOPN operator bits')
                ops.append([mul&15,(mul>>4)&7,tl,ar>>6,ar&31,dr&31,sr,sl&15,sl>>4,ssg,0,dr>>7])
            validate(25,base,ops)
            name=r[:32].split(b'\0',1)[0].decode('utf-8')
            result.append(dict(identity,name=name,base=base,ops=ops))
    return result,excluded

def tone_tables(data):
    text=data.decode('utf-8')
    block=text.split('static uint8_t default_inst',1)[1].split('}};',1)[0]
    block=re.sub(r'/\*.*?\*/|//[^\n]*','',block,flags=re.S)
    values=[int(x,16) for x in re.findall(r'0x([0-9a-fA-F]{2})',block)]
    if len(values)!=3*19*8:raise ValueError('unexpected emu2413 tone table layout')
    return [[values[(t*19+p)*8:(t*19+p+1)*8] for p in range(1,16)] for t in range(3)]

# Deliberate two-operator programs, not ROM/game replicas. Distinct ratios,
# feedback, waveforms and envelopes; no random name/parameter inflation.
ORIGINALS=[
 ('Reed Keys','Keys',[0x21,0x21,0x18,0x04,0xf4,0xe5,0x24,0x36]),
 ('Soft Tines','Keys',[0x01,0x01,0x24,0x00,0xf5,0xf3,0x42,0x35]),
 ('Wire Clav','Pluck',[0x03,0x01,0x12,0x05,0xf8,0xf7,0x68,0x58]),
 ('Hollow Pluck','Pluck',[0x02,0x01,0x18,0x10,0xf7,0xf5,0x46,0x57]),
 ('Rubber Bass','Bass',[0x21,0x20,0x10,0x06,0xf6,0xf4,0x36,0x25]),
 ('Round Sub','Bass',[0x21,0x20,0x30,0x00,0xf3,0xf2,0x34,0x25]),
 ('Pick Root','Bass',[0x02,0x00,0x19,0x05,0xf9,0xf5,0x58,0x36]),
 ('Narrow Reed','Lead',[0x22,0x21,0x18,0x16,0xf0,0xf0,0x07,0x07]),
 ('Soft Whistle','Lead',[0x21,0x21,0x38,0x00,0xc0,0xd0,0x05,0x06]),
 ('Brass Solo','Brass-Reed',[0x21,0x21,0x15,0x06,0xa3,0xc2,0x23,0x25]),
 ('Cloud Organ','Organ',[0x23,0x21,0x20,0x01,0xf0,0xf0,0x05,0x05]),
 ('Glass Pad','Pad',[0x47,0x61,0x24,0x00,0x73,0x82,0x34,0x35]),
 ('Warm Pad','Pad',[0x61,0x61,0x20,0x03,0x62,0x72,0x23,0x25]),
 ('Bronze Chime','Bell-Mallet',[0x07,0x01,0x18,0x00,0xf4,0xf3,0x56,0x46]),
 ('Ice Bell','Bell-Mallet',[0x0d,0x01,0x1c,0x00,0xf5,0xf2,0x66,0x35]),
 ('Wood Block','Percussion',[0x04,0x01,0x12,0x01,0xfa,0xf8,0xa8,0x88]),
 ('Metal Hit','Percussion',[0x0f,0x02,0x04,0x07,0xfb,0xf9,0xc9,0xa9]),
 ('Relay Buzz','FX',[0x2d,0x21,0x06,0x17,0xf0,0xf0,0x07,0x07]),
]

def convert_expansion(output,writer,builtins):
    from convert import GM,category
    sources=json.loads((ROOT/'tools/chip_banks/expansion-sources.json').read_text())
    data={}
    for s in sources:
        raw=(ROOT/s['path']).read_bytes()
        if hashlib.sha256(raw).hexdigest()!=s['sha256']:raise ValueError('expansion source hash mismatch')
        data[Path(s['path']).name]=raw
    records=[];excluded=[]
    def record(chip,bank,label,e,filename,source,license):
        records.append(dict(type=chip,bank_id=bank,bank=label,category=e['category'],name=e['name'],path=filename+'.cni',source=source,license=license,human_listened=False))
    genesis,omitted=parse_wopn(data['16bit-station.wopn']);excluded.extend(dict(e,source='16bit-station.wopn') for e in omitted)
    for e in genesis:
        e['name']=e['name'] or GM[e['program']];e['category']=category(dict(percussion=0,program=e['program']))
        filename=f"16bit-station-{e['bank']:03}-{e['program']:03}"
        write_patch(output,writer,25,e,filename);record(25,210,'16-Bit FM Music Station',e,filename,'16bit-station.wopn','CC0-1.0')
    for part in data['ymulator.opm'].decode('utf-8-sig').split('@:')[1:]:
        try:entry=parse_opm(('@:'+part).encode())[0]
        except ValueError as error:
            excluded.append(dict(source='ymulator.opm',entry=part.splitlines()[0],reason=str(error)));continue
        carriers=[8,8,8,8,10,14,14,15][entry['base'][1]] & entry['base'][11]
        if not any(carriers&(1<<i) and op[4]>0 and op[2]<127 for i,op in enumerate(entry['ops'])):
            excluded.append(dict(source='ymulator.opm',entry=part.splitlines()[0],reason='all carrier operators silent'));continue
        entry['base'][13]=211;entry['category']='Unsorted';filename=f"ymulator-{entry['base'][14]:03}"
        write_patch(output,writer,26,entry,filename);record(26,211,'YMulator Arcade Collection',entry,filename,'ymulator.opm','GPL-3.0-only')
    names=[['Violin','Guitar','Piano','Flute','Clarinet','Oboe','Trumpet','Organ','Horn','Synthesizer','Harpsichord','Vibraphone','Synth Bass','Acoustic Bass','Electric Guitar'],
           ['Buzzy Bell','Guitar','Wurly','Flute','Clarinet','Synth','Trumpet','Organ','Bells','Vibes','Vibraphone','Tutti','Fretless','Synth Bass','Sweep'],
           ['Electric Strings','Bow Wow','Electric Guitar','Organ','Clarinet','Saxophone','Trumpet','Street Organ','Synth Brass','Electric Piano','Bass','Vibraphone','Chimes','Tom Tom II','Noise']]
    tables=tone_tables(data['emu2413.c'])
    for chip in (17,18):
        template=(output/f'builtin-{chip}-01.cni').read_text()
        seen=set()
        for r in builtins:
            if r['type']==chip:
                line=re.search(r'- Tone bytes: (.*)',(output/r['path']).read_text())[1]
                seen.add(tuple(map(int,line.split(','))))
        palettes=[(220+chip*10+t,label,[(names[t][n],'Unsorted',patch) for n,patch in enumerate(table)],'emu2413.c','MIT') for t,(label,table) in enumerate(zip(['emu2413 YM2413','emu2413 VRC7','emu2413 YMF281B'],tables))]
        palettes.append((223+chip*10,'ChooChoo OPLL Programs',ORIGINALS,'expansion.py','MIT'))
        for bank,label,entries,source,license in palettes:
            for n,(name,cat,tone) in enumerate(entries):
                if tuple(tone) in seen:excluded.append(dict(source=source,type=chip,bank=label,name=name,reason='duplicate tone bytes'));continue
                seen.add(tuple(tone));filename=f'opll-{chip}-{bank}-{n:02}'
                text=re.sub(r'- Name: .*','- Name: '+name[:16],template)
                for field,value in [('Program','0'),('OPLL bank',str(bank)),('OPLL name',name),('Tone bytes',','.join(map(str,tone)))]:
                    text=re.sub(r'- '+field+r': .*','- '+field+': '+value,text)
                (output/(filename+'.cni')).write_text(text)
                subprocess.run([str(writer),'--validate',str(output/(filename+'.cni'))],check=True)
                record(chip,bank,label,dict(name=name,category=cat),filename,source,license)
    # Package source forms and complete notices alongside converted data.
    notices=output.parent.parent/'licenses/chip-banks/expansion';notices.mkdir(parents=True,exist_ok=True)
    for s in sources:
        shutil.copyfile(ROOT/s['path'],notices/Path(s['path']).name)
        shutil.copyfile(ROOT/s['license_path'],notices/Path(s['license_path']).name)
    shutil.copyfile(Path(__file__).with_name('expansion-NOTICE.txt'),notices/'README.txt')
    shutil.copyfile(Path(__file__),notices/'expansion.py')
    shutil.copyfile(Path(__file__).with_name('four_op.py'),notices/'four_op.py')
    (notices/'sources.json').write_text(json.dumps(sources,indent=2)+'\n')
    (output/'expansion-manifest.json').write_text(json.dumps(dict(sources=sources,entries=records,excluded=excluded),indent=2)+'\n')
    return records
