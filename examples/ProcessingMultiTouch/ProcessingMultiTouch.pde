/**
 * oscP5broadcastClient by andreas schlegel
 * an osc broadcast client.
 * an example for broadcast server is located in the oscP5broadcaster exmaple.
 * oscP5 website at http://www.sojamo.de/oscP5
 */

import oscP5.*;
import netP5.*;
import java.util.Iterator;
import java.util.Map;

// the object we will be using to handle OSC communication
OscP5 oscP5;

// a map from finger IDs (integers unique to each continuous finger touch) to a Finger instance
HashMap fingerIdMap;
// the fingers that should be added to the map during the next draw call, detected from OSC messages
ArrayList fingersToAdd;
// the fingers that have been lifted from the surface and should be removed from the mapping after rendering
ArrayList fingersToRemove;

// the port that we will be listening for osc signals over
int listenPort = 9109;
// the type tag for the small multitouch messages (no rotation or size)
String shortTypeTag = "iff";
// the type tag for the complete multitouch messages (full rotation and size)
String longTypeTag = "ifffffffiif";
// the number of milliseconds that we wait to remove a finger once we stop receiving messages
int timeToRemove = 10;

void setup() {
  size(640, 480);
  frameRate(30);
  strokeWeight(2.0);
  
  // create a new instance of oscP5 to listen to incoming osc messages
  oscP5 = new OscP5(this, listenPort);
  
  // initialize the data structures to keep track of fingers
  fingerIdMap = new HashMap();
  fingersToAdd = new ArrayList();
  fingersToRemove = new ArrayList();
}


void draw() {
  background(0);
  
  color(0.8);
  text("Fingers: " + fingerIdMap.size(), 10, 20);
  
  int curTime = millis();
  
  // add any new fingers we got from the OSC messages
  for (int i = 0; i < fingersToAdd.size(); i++)
  {
    Finger fingerToAdd = (Finger)fingersToAdd.get(i);
    fingerIdMap.put(fingerToAdd.id, fingerToAdd);
  }
  fingersToAdd.clear();
  
  // iterate through existing fingers and render them
  Iterator i = fingerIdMap.entrySet().iterator();
  while (i.hasNext())
  {
    Map.Entry me = (Map.Entry)i.next();
    Finger finger = (Finger)me.getValue();
    
    // if we haven't heard from this finger in a while,
    // it must have been lifted, so remove it
    if (curTime - finger.milliLastTouched > timeToRemove)
    {
      fingersToRemove.add(finger.id);
    }
    
    finger.render((float)width, (float)height);
  }
  
  // remove all the fingers that were lifted
  for (int j = 0; j < fingersToRemove.size(); j++)
  {
    Integer idToRemove = (Integer)fingersToRemove.get(j);
    fingerIdMap.remove(idToRemove);
  }
  fingersToRemove.clear();
}


// incoming osc message are forwarded to the oscEvent method.
void oscEvent(OscMessage oscMsg) {
  
  String addr = oscMsg.addrPattern();
  String typeTag = oscMsg.typetag();
  
  if (!addr.equals("/finger") || (!typeTag.equals(shortTypeTag) && !typeTag.equals(longTypeTag)))
  {
    return;
  }
  
  Integer fingerId = oscMsg.get(0).intValue();
  float posX = oscMsg.get(1).floatValue();
  float posY = oscMsg.get(2).floatValue();
  float velX = 0.0;
  float velY = 0.0;
  float angle = 0.0;
  float majorAxis = 20.0;
  float minorAxis = 20.0;
  Integer frame = 0;
  Integer state = 0;
  float size = 0.0;
  int time = millis();
  
  if (typeTag.equals(longTypeTag))
  {
    velX = oscMsg.get(3).floatValue();
    velY = oscMsg.get(4).floatValue();
    angle = oscMsg.get(5).floatValue();
    majorAxis = oscMsg.get(6).floatValue();
    minorAxis = oscMsg.get(7).floatValue();
    frame = oscMsg.get(8).intValue();
    state = oscMsg.get(9).intValue();
    size = oscMsg.get(10).floatValue();
  }
  
  Finger finger = (Finger)fingerIdMap.get(fingerId);
  // finger doesn't exist yet, so create it
  if (finger == null)
  {
    finger = new Finger(fingerId, time);
    fingersToAdd.add(finger);
  }
  finger.update(posX, posY, velX, velY, angle, majorAxis, minorAxis, time);
}
