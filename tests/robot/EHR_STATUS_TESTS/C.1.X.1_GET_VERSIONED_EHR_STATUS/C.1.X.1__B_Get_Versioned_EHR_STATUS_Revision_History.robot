# Copyright (c) 2019 Wladislaw Wagner (Vitasystems GmbH), Pablo Pazos (Hannover Medical School).
#
# This file is part of Project EHRbase
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.



*** Settings ***
Metadata    Version    0.1.0
Metadata    Author    *Wladislaw Wagner*
Metadata    Author    *Jake Smolka*
Metadata    Created    2021.01.26

Documentation   Preconditions:
...                 An EHR with known ehr_id should exist.
...
...             Postconditions:
...                 None
...
...             Flow:
...                 1. Invoke the get EHR_STATUS service by the existing ehr_id
...                 2. The result should be positive and retrieve a correspondent EHR_STATUS.
...                    The EHR_STATUS internal information should match the rules in which
...                    the EHR was created (see test flow Create EHR) and those should be verified:
...
...                    a) has or not a subject_id
...                    b) has correct value for is_modifiable
...                    c) has correct value for is_queryable
Metadata        TOP_TEST_SUITE    EHR_STATUS
Resource        ${EXECDIR}/robot/_resources/suite_settings.robot

# Suite Setup  startup SUT
# Suite Teardown  shutdown SUT

Force Tags



*** Test Cases ***
1. Get Revision History of Versioned Status Of Existing EHR (JSON)
    # Simple test

    prepare new request session    JSON    Prefer=return=representation

    create new EHR
    Should Be Equal As Strings    ${response.status}    201

    get revision history of versioned ehr_status of EHR
    Should Be Equal As Strings    ${response.status}    200
    ${length} =    Get Length    ${response.body} 	
    Should Be Equal As Integers 	${length} 	1

    ${item1} =    Get From List    ${response.body}    0
    Should Be Equal As Strings    ${ehrstatus_uid}    ${item1.version_id.value}


2. Get Revision History of Versioned Status Of Existing EHR With Two Status Versions (JSON)
    # Testing with two versions, so the result should list two history entries.

    prepare new request session    JSON    Prefer=return=representation

    create new EHR
    Should Be Equal As Strings    ${response.status}    201

    update EHR: set ehr_status is_queryable    ${TRUE}
    check response of 'update EHR' (JSON)

    get revision history of versioned ehr_status of EHR
    Should Be Equal As Strings    ${response.status}    200
    ${length} =    Get Length    ${response.body} 	
    Should Be Equal As Integers 	${length} 	2

    ${item1} =    Get From List    ${response.body}    0
    Should Be Equal As Strings    ${ehrstatus_uid}    ${item1.version_id.value}

    ${item2} =    Get From List    ${response.body}    1
    Should Be Equal As Strings    ${ehrstatus_uid[0:-1]}2    ${item2.version_id.value}


# !!! Blocked by https://github.com/ehrbase/project_management/issues/458 - uncomment if resolved!
# 3. Get Correct Ordered Revision History of Versioned Status Of Existing EHR With Two Status Versions (JSON)
#     # Testing with two versions like above, but checking the response more thoroughly.

#     Import Library    DateTime

#     prepare new request session    JSON    Prefer=return=representation

#     create new EHR
#     Should Be Equal As Strings    ${response.status}    201

#     update EHR: set ehr_status is_queryable    ${TRUE}
#     check response of 'update EHR' (JSON)

#     get revision history of versioned ehr_status of EHR
#     Should Be Equal As Strings    ${response.status}    200
#     ${length} =    Get Length    ${response.body} 	
#     Should Be Equal As Integers 	${length} 	2

#     # Attention: the following code is depending on the order of the array!

#     ${item1} =    Get From List    ${response.body}    0
#     Should Be Equal As Strings    ${ehrstatus_uid}    ${item1.version_id.value}
#     # check if change type is "creation"
#     ${audit1} =    Get From List    ${item1.audits}    0
#     Should Be Equal As Strings    creation    ${audit1.change_type.value}
#     # save timestamp to compare later
#     ${timestamp1} = 	Set Variable 	${audit1.time_committed.value}

#     ${item2} =    Get From List    ${response.body}    1
#     Should Be Equal As Strings    ${ehrstatus_uid[0:-1]}2    ${item2.version_id.value}
#     # check if change type is "modification"
#     ${audit2} =    Get From List    ${item2.audits}    0
#     Should Be Equal As Strings    modification    ${audit2.change_type.value}
#     # save timestamp, too.
#     ${timestamp2} = 	Set Variable 	${audit2.time_committed.value}

#     # check if this one is newer/bigger/higher than the creation timestamp.
#     # Note: currently the timestamp from EHRbase here as "," and "T", which is not supported
#     # But even if that changes in the future, the following lines should be okay as they just stop to be executed.
#     ${timestamp1fix} = 	Replace String 	${timestamp1} 	, 	.
#     ${timestamp2fix} = 	Replace String 	${timestamp2} 	, 	.
#     ${timestamp1fix} = 	Replace String 	${timestamp1fix} 	T 	${space}
#     ${timestamp2fix} = 	Replace String 	${timestamp2fix} 	T 	${space}

#     ${timediff} = 	Subtract Date From Date 	${timestamp2fix} 	${timestamp1fix}

#     # Idea: newer/higher timestamp - older/lesser timestamp = number larger than 0 IF correct
#     Should Be True 	${timediff} > 0


