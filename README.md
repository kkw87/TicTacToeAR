## TicTacToe AR

TicTacToeAR

An AR application that Is used to play a simple game of tic tac toe in AR with another player using their own separate device. 

Key Frameworks used : Multipeer Connectivity, ARKit, SceneKit 

## Project Screen Shot(s)

#### Example:   

[ PRETEND SCREEN SHOT IS HERE ]

[ PRETEND OTHER SCREEN SHOT IS HERE ]


The scope of this project was to gain familiarity with Apple’s ARKit as well as experimenting with multiplayer and data sharing between local devices using Apple’s Multipeer connectivity framework. The main goal of this project was to understand how ARKit could potentially work together with ARKit to make a multiplayer experience following Apple’s Swiftshot example. 

The original goal was to simply built a single player Tic Tac Toe game which would have allowed me to explore using the ARKit framework as well as SceneKit to place boards in the “AR” world and allowing user interaction. 

Two of the main challenges I faced in this project was placing a grid of nodes at a user specific position, as well as communication and synchronizing one game state between two devices in realtime. I spent some time really understanding how nodes can embed into each other while spending some trial and error understanding how a node placement will react to a user touch(a hit test).  The eventual solution was to make one SCNNode from SceneKit that embedded the 3x3 board of a tic tac toe game of additional SCN nodes. Positioning was then made with the parent node instead of each of the 9 board nodes. 

The other issue that was faced was transferring the world and game state from the host player to the joining player. My original implementation included used NSKeyedArchiver to encapsulate the world state, the current game state as well as the game board. This Implementation did not work and it was extremely inefficient to archive and sent the entire game board nodes from one device to another. 

The solution I ended up using was using was using KeyedArchive to capture and send the current AR world state. The current game state was instead transmitted using separate data structures using Swift’s Codeable protocol. 

The inefficiency of transmitting the entire game board node through Multipeer connectivity was addressed by adding a separate data structure that took the board’s current position as well as the state of every individual node that made up the game board. This was sent to the joining device which would simply adjust it’s own board location and update its own child nodes to match those sent by the host. 

A final challenge was synchronizing player moves and only allowing the current device’s “turn” to make a move. Player moves are sent to the other device using a separate datastructure using Swift’s Codeable protocol. When the other device in the multiplier session receives this data, it decodes it and updates the move on its own board and game to match those made by the sending device. 

In the end, the key frameworks used to build this app were Multipeer Connectivity, ARKit and SceneKit. The project also used MVVM to architect the code. 

