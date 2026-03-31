;Header and description

(define (domain hiflex_new)

;remove requirements that are not needed
(:requirements :strips :durative-actions :typing :equality :negative-preconditions :disjunctive-preconditions :conditional-effects :numeric-fluents) 

(:types
screwdriver gripper - tool
robotposition cartposition - position
storageposition - cartposition
cart robot - machine
traycart productcart toolcart - cart
containertray castortray profiletray - tray
trayable_assembly - assembly
tray assembly machine position - goalable
tool goalable
)



(:predicates
;robot positioned on place on axis
(robot_positioned_at ?robot - robot ?pos - robotposition)

;is object part of the goal state
(is_goal ?o - goalable)

;is assembly added_assembly
(is_added_assembly ?a - assembly)

;goals
(screw_assembly_to_assembly_goal)
(screw_bracket_to_assembly_goal)
(screw_profile_to_assembly_goal)
(screw_castor_to_assembly_goal)
(screw_container_to_assembly_goal)
(add_screw_to_assembly_goal)

;cart positioned on grid position
(cart_positioned_at ?cart - cart ?pos - cartposition)

;robotposition on axis with other robotposition
(robotposition_connected_to ?pos1 - robotposition ?pos2 - robotposition)

;position accessible from robot on position
(robot_can_reach_cartposition ?robot - robot ?pos_robo - robotposition ?pos_cart - cartposition)

;robot holding anything pickable (atomicpart, assembly, tool)
(robot_holding_assembly ?robot - robot ?obj - assembly)

;product or assembly on product cart
(productcart_carries_assembly ?obj - assembly ?cart - productcart)

;tool on tool cart
(toolcart_carries_tool ?tool - tool ?cart - toolcart)

;robot has tool equipped
(robot_has_tool ?tool - tool ?robot - robot)

;robot has tool gripper equipped
(robot_is_gripper ?robot - robot)

;robot has tool screwer equipped
(robot_is_screwer ?robot - robot)

;cart on position cant move yet because of other processes
(cartposition_is_blocked ?pos - cartposition)

;robot cant move yet because of other processes
(robot_blocked ?robot - robot)

;assembly has z rotation set
(assembly_is_rotated_z ?obj - assembly)

;assembly has xy rotation set
(assembly_is_rotated_xy ?obj - assembly)

;tray is on machine
(tray_on_machine ?tray - tray ?machine - machine)

;assembly is on tray
(tray_holds_assembly ?tray - tray ?obj - trayable_assembly)
)

(:functions
    (distance ?from - position ?to - position)
)

(:durative-action move_robot
    :parameters (?robot - robot ?from_pos - robotposition ?to_pos - robotposition)
    :duration (= ?duration 1)
    :condition (and
        (at start (robot_positioned_at ?robot ?from_pos))
        (at start (robotposition_connected_to ?from_pos ?to_pos))
        (at start (not (robot_blocked ?robot)))
        (at start (not (exists (?r1 - robot) (robot_positioned_at ?r1 ?to_pos))))
    )
    :effect (and
        (at end (not (robot_positioned_at ?robot ?from_pos)))
        (at end (robot_positioned_at ?robot ?to_pos))
    )
)

(:durative-action move_traycart
    :parameters (?cart - traycart ?from_pos - cartposition ?to_pos - cartposition)
    :duration (= ?duration (distance ?from_pos ?to_pos))
    :condition (and
        (at start (cart_positioned_at ?cart ?from_pos))
        (at start (not (exists (?c1 - cart) (cart_positioned_at ?c1 ?to_pos))))
        (at start (not (cartposition_is_blocked ?from_pos)))
    )
    :effect (and 
        (at start (not (cart_positioned_at ?cart ?from_pos)))
        (at end (cart_positioned_at ?cart ?to_pos))
    )
)

(:durative-action move_productcart
    :parameters (?cart - productcart ?from_pos - cartposition ?to_pos - cartposition)
    :duration (= ?duration (distance ?from_pos ?to_pos))
    :condition (and
        (at start (cart_positioned_at ?cart ?from_pos))
        (at start (not (exists (?c1 - cart) (cart_positioned_at ?c1 ?to_pos))))
        (at start (not (cartposition_is_blocked ?from_pos)))
        (at start (not (exists (?a1 - assembly) (productcart_carries_assembly ?a1 ?cart))))
    )
    :effect (and
        (at start (not (cart_positioned_at ?cart ?from_pos)))
        (at end (cart_positioned_at ?cart ?to_pos))
    )
)

(:durative-action move_productcart_and_rotate_assembly
    :parameters (?cart - productcart ?from_pos - cartposition ?to_pos - cartposition ?obj - assembly)
    :duration (= ?duration (distance ?from_pos ?to_pos))
    :condition (and
        (at start (cart_positioned_at ?cart ?from_pos))
        (at start (not (exists (?c1 - cart) (cart_positioned_at ?c1 ?to_pos))))
        (at start (not (cartposition_is_blocked ?from_pos)))
        (at start (productcart_carries_assembly ?obj ?cart))
    )
    :effect (and 
        (at start (not (cart_positioned_at ?cart ?from_pos)))
        (at end (cart_positioned_at ?cart ?to_pos))
        (at end (assembly_is_rotated_z ?obj))
    )
)

(:durative-action move_toolcart
    :parameters (?cart - toolcart ?from_pos - cartposition ?to_pos - cartposition)
    :duration (= ?duration (distance ?from_pos ?to_pos))
    :condition (and
        (at start (cart_positioned_at ?cart ?from_pos))
        (at start (not (exists (?c1 - cart) (cart_positioned_at ?c1 ?to_pos))))
        (at start (not (cartposition_is_blocked ?from_pos)))
    )
    :effect (and 
        (at start (not (cart_positioned_at ?cart ?from_pos)))
        (at end (cart_positioned_at ?cart ?to_pos))
    )
)

(:durative-action pick_from_traycart
    :parameters (?robot - robot ?pos_robo - robotposition ?cart - traycart ?tray - tray ?pos_cart - cartposition ?obj - trayable_assembly)
    :duration (=?duration 1)
    :condition (and
        (at start (robot_positioned_at ?robot ?pos_robo))
        (at start (robot_is_gripper ?robot))
        (at start (not (exists (?a1 - assembly) (robot_holding_assembly ?robot ?a1))))
        (at start (robot_can_reach_cartposition ?robot ?pos_robo ?pos_cart))
        (at start (cart_positioned_at ?cart ?pos_cart))
        (at start (tray_on_machine ?tray ?cart))
        (at start (tray_holds_assembly ?tray ?obj))
    )
    :effect (and
        (at start (robot_blocked ?robot))
        (at start (cartposition_is_blocked ?pos_cart))
        (at end (robot_holding_assembly ?robot ?obj))
        (at end (not (tray_holds_assembly ?tray ?obj)))
        (at end (not (cartposition_is_blocked ?pos_cart)))
        (at end (not (robot_blocked ?robot)))
    )
)

(:durative-action pick_from_productcart
    :parameters (?robot - robot ?pos_robo - robotposition ?pos_cart - cartposition ?obj - assembly ?cart - productcart)
    :duration (=?duration 1)
    :condition (and
        (at start (robot_positioned_at ?robot ?pos_robo))
        (at start (not (exists (?a1 - assembly) (robot_holding_assembly ?robot ?a1))))
        (at start (robot_can_reach_cartposition ?robot ?pos_robo ?pos_cart))
        (at start (cart_positioned_at ?cart ?pos_cart))
        (at start (productcart_carries_assembly ?obj ?cart))
        (at start (robot_is_gripper ?robot))
    )
    :effect (and
        (at start (robot_blocked ?robot))
        (at start (cartposition_is_blocked ?pos_cart))
        (at end (robot_holding_assembly ?robot ?obj))
        (at end (not (productcart_carries_assembly ?obj ?cart)))
        (at end (not (cartposition_is_blocked ?pos_cart)))
        (at end (not (robot_blocked ?robot)))
    )
)

(:durative-action place_on_tray
    :parameters (?robot - robot ?pos_robo - robotposition ?cart - traycart ?tray - tray ?pos_cart - cartposition ?obj - trayable_assembly)
    :duration (= ?duration 1)
    :condition (and
        (at start (robot_positioned_at ?robot ?pos_robo))
        (at start (robot_is_gripper ?robot))
        (at start (robot_holding_assembly ?robot ?obj))
        (at start (cart_positioned_at ?cart ?pos_cart))
        (at start (tray_on_machine ?tray ?cart))
        (at start (robot_can_reach_cartposition ?robot ?pos_robo ?pos_cart))
    )
    :effect (and
        (at start (robot_blocked ?robot))
        (at start (cartposition_is_blocked ?pos_cart))
        (at end (not (robot_holding_assembly ?robot ?obj)))
        (at end (tray_holds_assembly ?tray ?obj))
        (at start (not (cartposition_is_blocked ?pos_cart)))
        (at end (not (robot_blocked ?robot)))
    )
)

(:durative-action place_on_productcart
    :parameters (?robot - robot ?pos_robo - robotposition ?pos_cart - cartposition ?obj - assembly ?cart - productcart)
    :duration (= ?duration 1)
    :condition (and
        (at start (robot_positioned_at ?robot ?pos_robo))
        (at start (robot_holding_assembly ?robot ?obj))
        (at start (robot_can_reach_cartposition ?robot ?pos_robo ?pos_cart))
        (at start (robot_is_gripper ?robot))
        (at start (cart_positioned_at ?cart ?pos_cart))
        (at start (not (exists (?a1 - assembly) (productcart_carries_assembly ?a1 ?cart))))
    )
    :effect (and
        (at start (robot_blocked ?robot))
        (at start (cartposition_is_blocked ?pos_cart))
        (at end (not (robot_holding_assembly ?robot ?obj)))
        (at end (productcart_carries_assembly ?obj ?cart))
        (at end (assembly_is_rotated_xy ?obj))
        (at end (assembly_is_rotated_z ?obj))
        (at end (not (cartposition_is_blocked ?pos_cart)))
        (at end (not (robot_blocked ?robot)))
    )
)

(:durative-action get_tray_from_storage
    :parameters (?cart - traycart ?pos - storageposition ?tray - tray)
    :duration (= ?duration 1)
    :condition (and 
        (at start (cart_positioned_at ?cart ?pos))
        (at start (not (exists (?tc1 - traycart) (tray_on_machine ?tray ?tc1))))
    )
    :effect (and
        (at start (cartposition_is_blocked ?pos))
        (at end (tray_on_machine ?tray ?cart))
        (at end (not (cartposition_is_blocked ?pos)))
    )
)

(:durative-action swap_tool_to_gripper
    :parameters (?robot - robot ?pos_robo - robotposition ?tool_from - screwdriver ?tool_to - gripper ?pos_cart - cartposition ?cart - toolcart)
    :duration (= ?duration 1)
    :condition (and
        (at start (robot_positioned_at ?robot ?pos_robo))
        (at start (robot_has_tool ?tool_from ?robot))
        (at start (robot_is_screwer ?robot))
        (at start (cart_positioned_at ?cart ?pos_cart))
        (at start (robot_can_reach_cartposition ?robot ?pos_robo ?pos_cart))
        (at start (toolcart_carries_tool ?tool_to ?cart))
    )
    :effect (and
        (at start (robot_blocked ?robot))
        (at start (cartposition_is_blocked ?pos_cart))
        (at end (not (robot_has_tool ?tool_from ?robot)))
        (at end (robot_has_tool ?tool_to ?robot))
        (at end (not (robot_is_screwer ?robot)))
        (at end (robot_is_gripper ?robot))
        (at end (not (toolcart_carries_tool ?tool_to ?cart)))
        (at end (toolcart_carries_tool ?tool_from ?cart))
        (at end (not (cartposition_is_blocked ?pos_cart)))
        (at end (not (robot_blocked ?robot)))
    )
)

(:durative-action swap_tool_to_screwer
    :parameters (?robot - robot ?pos_robo - robotposition ?tool_from - gripper ?tool_to - screwdriver ?pos_cart - cartposition ?cart - toolcart)
    :duration (= ?duration 1)
    :condition (and
        (at start (robot_positioned_at ?robot ?pos_robo))
        (at start (robot_has_tool ?tool_from ?robot))
        (at start (robot_is_gripper ?robot))
        (at start (robot_can_reach_cartposition ?robot ?pos_robo ?pos_cart))
        (at start (cart_positioned_at ?cart ?pos_cart))
        (at start (toolcart_carries_tool ?tool_to ?cart))
    )
    :effect (and
        (at start (robot_blocked ?robot))
        (at start (cartposition_is_blocked ?pos_cart))
        (at end (not (robot_has_tool ?tool_from ?robot)))
        (at end (robot_has_tool ?tool_to ?robot))
        (at end (not (robot_is_gripper ?robot)))
        (at end (robot_is_screwer ?robot))
        (at end (not (toolcart_carries_tool ?tool_to ?cart)))
        (at end (toolcart_carries_tool ?tool_from ?cart))
        (at end (not (cartposition_is_blocked ?pos_cart)))
        (at end (not (robot_blocked ?robot)))
    )
)

; (:durative-action robotteam_handover_pickable
;     :parameters (?robot - robot ?robot2 - robot ?pos_from - robotposition ?pos_from2 - robotposition ?pos_to - cartposition ?obj - pickable )
;     :duration (=?duration 1)
;     :condition (at start (and
;         (robot_positioned_at ?robot ?pos_from)
;         (robot_positioned_at ?robot2 ?pos_from2)
;         (not (exists (?pick - pickable) (holding_workable ?robot ?pick)))
;         (can_reach ?robot ?pos_from ?pos_to)
;         (can_reach ?robot2 ?pos_from2 ?pos_to)
;         (holding_workable ?robot2 ?obj)
;         (is_gripper ?robot)
;     ))
;     :effect (and
;         (at start (blocked_position?pos_to))
;         (at end (and
;             (holding_workable ?robot ?obj)
;             (not (holding_workable ?robot2 ?obj))
;             (not (holding_profile ?robot))
;             (not (blocked_position ?pos_to))
;         ))
;     )
; )

(:durative-action screw_assembly_to_assembly
    :parameters (?screwer - robot ?picker - robot ?cart - productcart ?work_pos - cartposition ?base_assembly - assembly ?added_assembly - assembly)
    :duration (=?duration 1)
    :condition (and
        (at start (is_goal ?screwer))
        (at start (is_goal ?picker))
        (at start (is_goal ?base_assembly))
        (at start (is_goal ?added_assembly))
        (at start (is_added_assembly ?added_assembly))
        (at start (is_goal ?work_pos))
        (at start (is_goal ?cart))
        (at start (assembly_is_rotated_xy ?base_assembly))
        (at start (assembly_is_rotated_z ?base_assembly))
        (at start (cart_positioned_at ?cart ?work_pos))
        (at start (productcart_carries_assembly ?base_assembly ?cart))
        (at start (exists (?rp1 - robotposition) (and
            (robot_positioned_at ?screwer ?rp1)
            (robot_can_reach_cartposition ?screwer ?rp1 ?work_pos)
        )))
        (at start (exists (?rp1 - robotposition) (and
            (robot_positioned_at ?picker ?rp1)
            (robot_can_reach_cartposition ?picker ?rp1 ?work_pos)
        )))
        (at start (robot_holding_assembly ?picker ?added_assembly))
        (at start (robot_is_screwer ?screwer))
        (at start (robot_is_gripper ?picker))
    )
    :effect 
        (at end (screw_assembly_to_assembly_goal))
)

(:durative-action screw_bracket_to_assembly
    :parameters (?screwer - robot ?picker - robot ?cart - productcart ?work_pos - cartposition ?base_assembly - assembly)
    :duration (=?duration 1)
    :condition (and
        (at start (is_goal ?screwer))
        (at start (is_goal ?picker))
        (at start (is_goal ?base_assembly))
        (at start (is_goal ?cart))
        (at start (is_goal ?work_pos))
        (at start (assembly_is_rotated_xy ?base_assembly))
        (at start (assembly_is_rotated_z ?base_assembly))
        (at start (cart_positioned_at ?cart ?work_pos))
        (at start (productcart_carries_assembly ?base_assembly ?cart))
        (at start (not (exists (?a1 - assembly) (robot_holding_assembly ?picker ?a1))))
        (at start (exists (?rp1 - robotposition) (and
            (robot_positioned_at ?screwer ?rp1)
            (robot_can_reach_cartposition ?screwer ?rp1 ?work_pos)
        )))
        (at start (exists (?rp1 - robotposition) (and
            (robot_positioned_at ?picker ?rp1)
            (robot_can_reach_cartposition ?picker ?rp1 ?work_pos)
        )))
        (at start (robot_is_screwer ?screwer))
        (at start (robot_is_gripper ?picker))
    )
    :effect 
        (at end (screw_bracket_to_assembly_goal))
)

(:durative-action add_screw_to_assembly
    :parameters (?screwer - robot ?picker - robot ?cart - productcart ?work_pos - cartposition ?base_assembly - assembly)
    :duration (=?duration 1)
    :condition (and
        (at start (is_goal ?screwer))
        (at start (is_goal ?picker))
        (at start (is_goal ?base_assembly))
        (at start (is_goal ?work_pos))
        (at start (is_goal ?cart))
        (at start (assembly_is_rotated_xy ?base_assembly))
        (at start (assembly_is_rotated_z ?base_assembly))
        (at start (cart_positioned_at ?cart ?work_pos))
        (at start (productcart_carries_assembly ?base_assembly ?cart))
        (at start (not (exists (?a1 - assembly) (robot_holding_assembly ?picker ?a1))))
        (at start (exists (?rp1 - robotposition) (and
            (robot_positioned_at ?screwer ?rp1)
            (robot_can_reach_cartposition ?screwer ?rp1 ?work_pos)
        )))
        (at start (exists (?rp1 - robotposition) (and
            (robot_positioned_at ?picker ?rp1)
            (robot_can_reach_cartposition ?picker ?rp1 ?work_pos)
        )))
        (at start (robot_is_screwer ?screwer))
        (at start (robot_is_gripper ?picker))
    )
    :effect 
        (at end (add_screw_to_assembly_goal))
)

; (:durative-action screw_castor_to_assembly
;     :parameters (?screwer - robot ?picker - robot ?cart - productcart ?work_pos - cartposition ?base_assembly - assembly ?tray - castortray ?helper_pos - cartposition)
;     :duration (= ?duration 1)
;     :condition (and
;         (at start (is_goal ?screwer))
;         (at start (is_goal ?picker))
;         (at start (is_goal ?work_pos))
;         (at start (is_goal ?cart))
;         (at start (is_goal ?base_assembly))
;         (at start (is_goal ?tray))
;         (at start (assembly_is_rotated_xy ?base_assembly))
;         (at start (assembly_is_rotated_z ?base_assembly))
;         (at start (cart_positioned_at ?cart ?work_pos))
;         (at start (productcart_carries_assembly ?base_assembly ?cart))
;         (at start (not (exists (?a1 - assembly) (robot_holding_assembly ?picker ?a1))))
;         (at start (exists (?c1 - traycart) (and
;             (tray_on_machine ?tray ?c1)
;             (cart_positioned_at ?c1 ?helper_pos)
;         )))
;         (at start (exists (?rp1 - robotposition) (and
;             (robot_positioned_at ?screwer ?rp1)
;             (robot_can_reach_cartposition ?screwer ?rp1 ?work_pos)
;             (robot_can_reach_cartposition ?screwer ?rp1 ?helper_pos)
;         )))
;         (at start (exists (?rp1 - robotposition) (and
;             (robot_positioned_at ?picker ?rp1)
;             (robot_can_reach_cartposition ?picker ?rp1 ?work_pos)
;             (robot_can_reach_cartposition ?picker ?rp1 ?helper_pos)
;         )))
;         (at start (robot_is_screwer ?screwer))
;         (at start (robot_is_gripper ?picker))
;     )
;     :effect
;         (at end (screw_castor_to_assembly_goal))
; )

; (:durative-action screw_container_to_assembly
;     :parameters (?screwer - robot ?picker - robot ?cart - productcart ?work_pos - cartposition ?base_assembly - assembly ?tray - containertray ?helper_pos - cartposition)
;     :duration (= ?duration 1)
;     :condition (and
;         (at start (is_goal ?screwer))
;         (at start (is_goal ?picker))
;         (at start (is_goal ?work_pos))
;         (at start (is_goal ?cart))
;         (at start (is_goal ?base_assembly))
;         (at start (is_goal ?tray))
;         (at start (assembly_is_rotated_xy ?base_assembly))
;         (at start (assembly_is_rotated_z ?base_assembly))
;         (at start (cart_positioned_at ?cart ?work_pos))
;         (at start (productcart_carries_assembly ?base_assembly ?cart))
;         (at start (not (exists (?a1 - assembly) (robot_holding_assembly ?picker ?a1))))
;         (at start (exists (?c1 - traycart) (and
;             (tray_on_machine ?tray ?c1)
;             (cart_positioned_at ?c1 ?helper_pos)
;         )))
;         (at start (exists (?rp1 - robotposition) (and
;             (robot_positioned_at ?screwer ?rp1)
;             (robot_can_reach_cartposition ?screwer ?rp1 ?work_pos)
;             (robot_can_reach_cartposition ?screwer ?rp1 ?helper_pos)
;         )))
;         (at start (exists (?rp1 - robotposition) (and
;             (robot_positioned_at ?picker ?rp1)
;             (robot_can_reach_cartposition ?picker ?rp1 ?work_pos)
;             (robot_can_reach_cartposition ?picker ?rp1 ?helper_pos)
;         )))
;         (at start (robot_is_screwer ?screwer))
;         (at start (robot_is_gripper ?picker))
;     )
;     :effect
;         (at end (screw_container_to_assembly_goal))
; )

)