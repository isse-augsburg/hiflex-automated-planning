# Supplementary Materials for Automated Orchestration in a Real-World Self-Organizing Manufacturing Cell

In this repository, we provide additional data and videos.

## Proof-of-Concept Video Materials

If the videos do not autoplay, please download them from the subfolder.

In the first video [Videos/Construction of a Single Frame.mp4](Videos/Construction%20of%20a%20Single%20Frame.mp4), you can observe the complete process of producing a sample product frame within the virtua representation of our system.
Each production step is executed sequentially, starting with the formation of an appropriate team.
Using the automated planning approach, an executable orchestration is generated, which transitions the system to a new state for the next production step.
For the recording we used LPG-TD with configuration q.

In the second video [Videos/Real-Cell.mp4](Videos/Real-Cell.mp4), you can see the real system executing an example orchestration with actual robots and carts.
Some parameters required for this process (e.g., trajectories, positions) are manually determined, but the orchestration itself is derived from our described framework.

## Example Files for the Evaluated Automated Planning

### PDDL Domain File

The PDDL domain file used in the evaluations can be found [here](PDDL/domain.pddl).

### PDDL Problem File Examples

Example problem files are available:
- For `screw_bracket_to_assembly_goal`, see [PDDL/problem_screw_bracket_to_assembly_goal.pddl](PDDL/problem_screw_bracket_to_assembly_goal.pddl).
- For `screw_assembly_to_assembly_goal`, see [PDDL/problem_screw_assembly_to_assembly_goal.pddl](PDDL/problem_screw_assembly_to_assembly_goal.pddl).
