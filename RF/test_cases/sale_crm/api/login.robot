*** Settings ***
Library  SeleniumLibrary
Library  RequestsLibrary
Library  Collections
Library  JSONLibrary
Library  String

Suite Teardown  Close Browser

*** Variables ***

${url}      https://staging-crm.sabye-songkran.com/
${getUri}   api/view/v1alpha1/views/users/users
${postUri}  api/user/v1alpha1/users

*** Test Cases ***

1. Init
    Open Browser    ${url}  chrome
    Wait Until Element Is Visible   name:identifier    timeout=None     error=None
    Input Text    name:identifier   dung10@gmail.com
    Input Text    name:password     Dungnguyen@
    Click Button  Xpath://*[@id="root"]/div/div/form/div[3]/button
    ${cookie}=   Get Cookies
    ${headers}=  Create Dictionary  content-type=application/json   cookie=${cookie}
    ${random}=   Evaluate  random.randint(0, 999)
    ${email}=    Catenate  dungx_${random}@gmail.com
    Set Suite Variable     ${headers}
    Set Suite Variable     ${email}
    CREATE SESSION         User    ${url}     headers=${headers}     verify=true

2. Get User

    ${response}=  GET On Session              User    ${getUri}
                  Should Be Equal As Numbers  200     ${response.status_code}

3. Create User

    ${response}=  POST On Session       User  ${postUri}    data={"humanId":"${email}","firstName":"dung","lastName":"Nguyen","role":"roles/admin","annotations":{}}
           Should Be Equal As Numbers   200                 ${response.status_code}
    ${id}=        Get Value From Json   ${response.json()}  $..humanId
    @{name}=      Get Value From Json   ${response.json()}  $..name
    ${name}=      Convert to String     @{name}
                  Set Suite Variable    ${id}
                  Set Suite Variable    ${name}


4. Edit User

    ${editUri}=   Catenate              SEPARATOR=  api/user/v1alpha1/  ${name}
    ${response}=  PATCH On Session      User     ${editUri}    data={"humanId":"${id}","firstName":"dung1212","lastName":"Nguyen","role":"roles/admin","annotations":{}}
           Should Be Equal As Numbers   200      ${response.status_code}
                  Set Suite Variable    ${editUri}

5. Delete User

    ${response}=  DELETE On Session     User      ${editUri}
           Should Be Equal As Numbers   200       ${response.status_code}

