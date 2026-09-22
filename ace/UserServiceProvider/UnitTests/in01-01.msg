<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:user="http://example.com/userservice">
   <soapenv:Header/>
   <soapenv:Body>
      <user:CreateUserRequest>
         <name>test user</name>
         <role>tester</role>
      </user:CreateUserRequest>
   </soapenv:Body>
</soapenv:Envelope>
