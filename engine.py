import json,sys,threading,queue
import hid
from openrgb import OpenRGBClient
from openrgb.utils import RGBColor
VID,PID=0x0416,0x0125
dev=None;razer_devices=[]
try:
 dev=hid.device();dev.open(VID,PID)
except Exception as e: print('SOYO:',e,file=sys.stderr)
try:
 rgb=OpenRGBClient(name='Chroma Sync Studio')
 razer_devices=[d for d in rgb.devices if 'razer' in d.name.lower()]
 for item in razer_devices:
  try:item.set_mode('Direct')
  except Exception as e:print('OpenRGB direct mode:',e,file=sys.stderr)
 print('OpenRGB Razer devices:',len(razer_devices),file=sys.stderr)
except Exception as e: print('OpenRGB:',e,file=sys.stderr)
def soyo(r,g,b,brightness=255):
    if not dev:return
    for c in (1,2):dev.write(bytes((2,c,100,0,0,0,0,0)));dev.write(bytes((3,c,17,r,g,b,max(0,min(255,brightness)),255)))
def razer(r,g,b):
    color=RGBColor(r,g,b)
    for item in razer_devices:
     try:item.set_color(color)
     except Exception as e:print('OpenRGB frame:',e,file=sys.stderr)
frames=queue.Queue(maxsize=1)
def read_frames():
 for line in sys.stdin:
  try:x=json.loads(line)
  except Exception as e:print('JSON:',e,file=sys.stderr);continue
  try:frames.get_nowait()
  except queue.Empty:pass
  try:frames.put_nowait(x)
  except queue.Full:pass
threading.Thread(target=read_frames,daemon=True).start()
while True:
 try:
  x=frames.get();r,g,b=x['red'],x['green'],x['blue']
  if x.get('useSoyo'):soyo(r,g,b,x.get('brightness',255))
  if x.get('useRazer'):razer(r,g,b)
 except Exception as e:print('Frame:',e,file=sys.stderr)
