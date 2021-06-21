#!/usr/bin/env bash
# Send alert when UPS event occurs
# SPDX-License-Identifier: GPL-3.0-or-later
# Copyright © 2021 林博仁(Buo-ren, Lin) <Buo.Ren.Lin@gmail.com>

set \
    -o errexit \
    -o errtrace \
    -o pipefail \
    -o nounset

trap_err(){
    printf \
        '\nScript prematurely aborted on the "%s" command at the line %s of the %s function with the exit status %u.\n' \
        "${BASH_COMMAND}" \
        "${BASH_LINENO[0]}" \
        "${FUNCNAME[1]}" \
        "${?}" \
        1>&2
}
trap trap_err ERR

event_name=
case "${EVENT}" in
    ABNORMAL)
        case "${EVENT_CONDITION}" in
            NO_NEUTRAL)
                event_name='Input is no neutral.'
            ;;
            WIRING_FAULT)
                event_name='Site wiring fault.'
            ;;
            *)
                event_name='UPS is abnormal.'
            ;;
        esac
    ;;
    ALL_SOURCE_FAILURE)
        event_name='Both input sources have power loss, ATS will not change input source.'
    ;;
    ATS_FAULT)
        event_name='ATS is faulty.'
    ;;
    BATTERY_CRITICAL_LOW)
        event_name='Battery capacity is critically low.'
    ;;
    BATTERY_FULL)
        event_name='Battery is fully charged.'
    ;;
    BATTERY_EXHAUSTED)
        event_name='The battery has been exhausted.'
    ;;
    BYPASS_FAILURE)
        event_name='Bypass power is failure.'
    ;;
    CAPACITY_INSUFFICIENT)
        event_name='Inverter capacity is insufficient.'
    ;;
    COMMAND_TEST_EVENT)
        event_name='Test event, please ignore.'
    ;;
    COMMUNICATION_FAILURE)
        case "${EVENT_CONDITION}" in
            LOST_IN_LOCAL)
                event_name='Local communication lost.'
            ;;
            LOST_IN_NETWORK)
                event_name='Network communication lost.'
            ;;
            *)
                event_name='Unknown communication error.'
            ;;
        esac
    ;;
    CURRENT_SOURCE_FAILURE)
        event_name='ATS has automatically switched to redundant power source.'
    ;;
    # NOTE: Does this event even triggerable?
    EMERGENCY_OFF)
        event_name='EPO is active.'
    ;;
    ENTER_BYPASS)
        event_name='Enters bypass mode.'
    ;;
    ENV_SENSOR_LOST)
        event_name='Environmental sensor is not responsive.'
    ;;
    ENV_SENSOR_OVERDRY)
        event_name='Humidity is under the low threshold.'
    ;;
    ENV_SENSOR_OVERHEAT)
        event_name='Temperature is over the high threshold.'
    ;;
    ENV_SENSOR_OVERWET)
        event_name='Humidity is over the high threshold.'
    ;;
    ENV_SENSOR_UNDERCOOL)
        event_name='Temperature is under the low threshold.'
    ;;
    FATAL_ABNORMAL)
        case "${EVENT_CONDITION}" in
            BATTERY_REVERSED)
                event_name='The polarity of battery is reversed.'
            ;;
            BYPASS_OVERLOAD)
                event_name='Bypass is overloaded.'
            ;;
            BYPASS_SEQUENCE_ERROR)
                event_name='The phase sequence of bypass is wrong.'
            ;;
            MODULE_OVERLOAD)
                event_name='Module is overloaded.'
            ;;
            MODULE_INVERTER_OVERHEAT)
                event_name='Module inverter is overheated.'
            ;;
            MODULE_INVERTER_PROTECTED)
                event_name='Module inverter is protected.'
            ;;
            MODULE_RECTIFIER_OVERHEAT)
                event_name='Module rectifier is overheated.'
            ;;
            OUTPUT_OVERLOAD)
                event_name='Output is overloaded.'
            ;;
            SHORT_CIRCUIT)
                event_name='Output circuit-short.'
            ;;
            *)
                event_name='UPS is fatal abnormal.'
            ;;
        esac
    ;;
    FAULT)
        case "${EVENT_CONDITION}" in
            BYPASS_FAN_FAULT)
                event_name='Bypass fan is faulty.'
            ;;
            BYPASS_FAULT)
                event_name='Bypass is faulty.'
            ;;
            GENERIC_FAULT)
                event_name='UPS is faulty.'
            ;;
            MODULE_FAN_FAULT)
                event_name='Module fan is faulty.'
            ;;
            MODULE_INVERTER_FAULT)
                event_name='Module inverter is faulty.'
            ;;
            MODULE_RECTIFIER_FAULT)
                event_name='Module rectifier is faulty.'
            ;;
            *)
                event_name='Unknown fault.'
            ;;
        esac
    ;;
    INPUT_NEAR_OVERLOAD)
        event_name='Input is near overload.'
    ;;
    INPUT_OVERLOAD)
        event_name='Input is overload.'
    ;;
    LOSS_REDUNDANT)
        event_name='Power redundancy is not enough.'
    ;;
    MBO_OUTLET_NEAR_OVERLOAD)
        event_name='A PDU outlet is near overload.'
    ;;
    MBO_OUTLET_OVERLOAD)
        event_name='A PDU outlet is overloaded.'
    ;;
    NO_BATTERY)
        event_name='Battery is not present.'
    ;;
    OUTPUT_WILL_STOP)
        event_name='The output power is going to stop soon.'
    ;;
    POWER_LOST)
        event_name='Power supply redundancy has been lost.'
    ;;
    REDUNDANT_SOURCE_FAILURE)
        event_name='ATS redundant power source has experienced a power failure.'
    ;;
    RUNTIME_INSUFFICIENT)
        event_name='Available runtime is insufficient.'
    ;;
    RUNTIME_WILL_EXHAUST)
        event_name='Remaining runtime will be exhausted.'
    ;;
    SHUTDOWN)
        event_name='Shutdown initiated.'
    ;;
    SHUTDOWN_TIME_INSUFFICIENT)
        event_name='Shutdown time is in insufficient.'
    ;;
    URGENT_COMMUNICATION_FAILURE)
        case "${EVENT_CONDITION}" in
            LOST_IN_LOCAL)
                event_name='Local communication lost in a power event.'
            ;;
            LOST_IN_NETWORK)
                event_name='Network communication lost in a power event.'
            ;;
            *)
                event_name='Unknown urgent communication failure.'
            ;;
        esac
    ;;
    UTILITY_FAILURE)
        event_name='Utility power failure.'
    ;;
    *)
        event_name='Unknown event.'
    ;;
esac

alert_message="# UPS Alert #"$'\n\n'"Event name: ${event_name:-N/A}(${EVENT})"$'\n'"Event condition: ${EVENT_CONDITION:-N/A}"$'\n'"Event stage: ${EVENT_STAGE}"$'\n'
printf "%s" "${alert_message}"
