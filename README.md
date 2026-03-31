# Supplementary Materials for Automated Orchestration in a Real-World Self-Organizing Manufacturing Cell

In this repository, we provide additional data and videos.

## Proof-of-Concept Video Materials

In the first video, you can observe the complete process of producing a sample product frame within the digital twin of our system.
Each production step is executed sequentially, starting with the formation of an appropriate team.
Using the automated planning approach, an executable orchestration is generated, which transitions the system to a new state for the next production step.

In the second video, you can see the real system executing an example orchestration with actual robots and carts.
Some parameters required for this process (e.g., trajectories, positions) are manually determined, but the orchestration itself is derived from our described framework.

## Example Files for the Evaluated Automated Planning

### PDDL Domain File

The PDDL domain file used in the evaluations can be found [here](PDDL/domain.pddl).

### PDDL Problem File Examples

Example problem files are available:
- For `screw_bracket_to_assembly_goal`, see [PDDL/problem_screw_bracket_to_assembly_goal.pddl](PDDL/problem_screw_bracket_to_assembly_goal.pddl).
- For `screw_assembly_to_assembly_goal`, see [PDDL/problem_screw_assembly_to_assembly_goal.pddl](PDDL/problem_screw_assembly_to_assembly_goal.pddl).
