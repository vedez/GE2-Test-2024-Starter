# Game Engines 2 Lab Test 2024

Click for a video of the creature creation system you will create today:

[![YouTube](http://img.youtube.com/vi/I_KU-wuzS7c/0.jpg)](https://www.youtube.com/watch?v=I_KU-wuzS7c)

- Fork this repo
- Clone your fork
- Open either the Godot or the Unity starter project
- Open exam_scene 
- Modify creature_generator.gd
- Add fields for length, frequency, start_angle, base_size, multiplier
- Modify the code in _process in creature_genereator.gd to draw the gizmo as per the video showing where the parts will be generated as spheres. 
- You need to calculate the size of each cube and its position in world space. 
- I suggest you draw a diagram and work this out on paper first. Use a sin wave function to determine the size. 
- Frequency controls how often the sin wave will repeat in the length of the creature. Start angle is an offset to add. base_size is the smallest segment size and multiplier * base_size is the largest. You can use the remap function.
- Modify the code in _ready to create the creature from a head scene and a body scene. The code will create each segment from packed scenes and set the size. I suggest you use CSGBox nodes as these have a size field. The head will be a Boid with a CSGBox3D as a child and the body will be just a CSGBox3D
- The head scene should have Harmonic and NoiseWander attached. 
- The boid should start paused. Pressing p will unpause.

## Marking Scheme

| Description | Marks |
|-------------|-------|
| Adding fields | 10 marks |
| Gizmo drawing | 30 marks |
| Creating the head and body scenes/prefabs | 10 marks |
| Instantiating the segments | 30 marks |
| Any other cool thing | 20 marks |

You should make a commit with a message every 20 minutes

[Submit your repo](https://forms.office.com/Pages/ResponsePage.aspx?id=yxdjdkjpX06M7Nq8ji_V2ou3qmFXqEdGlmiD1Myl3gNURTdONUhIMEFLTktNMzhGRkRDWkdMS1BQQy4u)
