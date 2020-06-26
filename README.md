# Crypt models
Code relating to crypt models.
The folder Chaste_models features models written in C++ using the package Chaste (see https://chaste.cs.ox.ac.uk/)
Chaste models are all for a fixed supporting structure (i.e. a non-deformable membrane) that doesn't allow buckling, but allows cells to be squeezed out of the monolayer.
The folder Matlab_models contains novel models written in matlab. These implement a deformable supporting tissue/membrane, and introduce a vertex model that allows cells to be completely separated (see example code below).
This is a repository for my PhD thesis work, it's not guaranteed to be well organised.

# Matlab models
Matlab_models/RectangularCell contains the models based on the interialess, drag dominated equations of motion for a rigid body.
If you wish to use them, you only need the code contained in src/
To run a simulation, choose a type of simulation from src/simulation/ and look at the constructor to see what variables are needed.
Make sure you add src/ to your matlab path.
Recommended simulations: CellGrowing, FixedDomain, RingOfCells, FreeCellTest
Others are experimental and may or may not work.
Normal values for each parameter are generally between 1 and 20.
You can build your own simulation by inheriting from AbstractCellSimulation and using nodes, elements, cells, cell cycle models, force laws, and space partitions, but currently there is minimal support for how to do this, apart from comments that I may have left for myself.
Nevertheless, I hope it is somewhat intuitive.
There is some error catching to help you on your way.

# Example code
```
p = 10;
g = 10;
seed = 1;
% p and g are cell cycle phase lengths, must be at least 1
% seed sets the rng seed for reproducibility
t = FreeCellTest(p, g, seed);
% if necessary, the time step size can be set by t.dt, default is 0.005hrs
% You can run the simulator in several ways:
% t.NextTimeStep; % Calculates the next time step
% t.NTimeSteps(1000); % Calculates the next N time steps
% t.RunToTime(40); % This runs the simulation to time t = 40hrs
% Simulating this way, you can only visualise single time steps
t.Visualise;
% t.VisualiseWireFrame;
% If the simulation is not too large, you can watch it as it runs
t.Animate(1000,20); % First arg, number of time steps to simulate, second arg, update frequency - here it is once every 20 time steps
% If the simulation contains components that aren't part of a cell use
% t.AnimateWireFrame(1000,20);

% If you want animation of the end results, use
v = Visualiser(11,'FreeCellTest/SpatialState/'); 
% The first arg is 11 for FreeCellTest, and 5 for everything else.
% The first part of the string is the name of the simulation.
% To save the data for the Visualiser, the simulation must have a spatial state writer. See lines 125 and 126 of CellGrowing
% NOTE: the Visualiser uses the matlab function readmatrix, which only exists after R2019b. I've found it to be extremely buggy, so there is no guarantee Visualiser will work, even if you're using the latest version.
```
