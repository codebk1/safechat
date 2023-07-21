![safechat](https://github.com/codebk1/safechat/assets/20027710/eb3982be-2f21-4697-8bc9-2c59a4fee97a)

Mobile chat application with **end-to-end** encryption and **SRP** (Secure Remote Password) authentication. Created in Flutter :blue_heart:

https://github.com/codebk1/safechat/assets/20027710/c9b571d6-0f06-43e9-8b15-f18e933fcbd8

## Encryption    
Used algorithms:
- **Argon2id** - key derivation function,
- **ChaCha20 (Poly1305)** - symmetric encryption,
- **RSA (OAEP)** - asymmetric encryption.

Encryption implemented in [encryption_service.dart](./lib/utils/encryption_service.dart).

## SRP
**SRP** is a specification that allows clients to authenticate without the need to transmit password to an backend authentication system. The latest version of the protocol is 
**SRP-6a**, which is described in [RFC 5054](https://datatracker.ietf.org/doc/html/rfc5054) and implemented in [srp.dart](./lib/utils/srp.dart).

### Registration flow
The registration process in accordance with the SRP-6a specification, involves collecting from the customer the identification value (I) of a given user, e.g. email address and password (P). Based on the received data, the following values are determined:
- **s** - "salt" (random value),
- **x** - H(s | H(I | ":" | P)), where | is strings concatenation,
- **v** - g^x % N.

<img width="477" alt="srp-registration" src="https://github.com/codebk1/safechat/assets/20027710/f1057362-208c-43c7-b915-43a41628c464">

### Login flow
1. Collect a unique identifier **I** from the user (such as email) and a password **P**.
2. Determine the private value **a** and the public value **A**, according to the following requirements:
   - **a** = random 256-bit value,
   - **A** = g^a % N.
3. Send the **I** and **A** values to the authentication server.
4. The authentication server based on the received user identifier (I) retrieves the values of **s** and **v** from the database.
5. In addition, the server according to the version of the SRP-6a specification determines the value of **k = H(N | PAD(g))**, so that a person who knows the parameters of the group (N, g), is unable to carry out a password guessing attack.
6. In the next step, analogous to the client, the server generates a private value **b** and a public value **B**, according to the following requirements:
   - **b** = random 256 bit value,
   - **B** = k * v + g^b % N.
7. Then the server in response to the client's request, sends back the values of **s** and **B**.
8. Client after receiving the above values and before proceeding with the rest of the authentication process, verifies the authenticity of the server by validating the received value of B, according to the following condition: **B % N != 0**.
9. If the value of B did not meet the condition, authentication is terminated, otherwise the client determines the next variables:
   - **x** = H(s | H(I | ":" | P)),
   - **u** = H(PAD(A) | PAD(B)), where PAD is a function that completes a given integer with zeros to a length equal to N.
10. Based on the determined values, the client calculates the variable **S = (B - (k * g^x)) ^ (a + (u * x)) % N**, and then determines the key **K = H(S)** according to the specification. The use of the variable **u** in SRP-6a, makes it impossible for a person to authenticate with only the verifier (v) of a given user.
11. Then the client, using its designated key (K), determines the value **M1 = H(PAD(A) | PAD(B) | PAD(K))**, which will be sent to the authentication server as a confirmation of the client's identity.
12. The server, after receiving the value of **M1** from the client, determines its own key (K), according to the following formulas:
    - **S** = (A * v^u) ^ b % N,
    - **K** = H(S).
13. Then the server compares the received variable **M1** with the value **M1 = H(PAD(A), PAD(B), PAD(K))** determined from its own key (K). If these values are identical, the identity of the client is confirmed.
14. In addition, the server can determine the value of **M2 = H(A, M1, K)**, based on the determined variable **M1**, and then send it to the client.
15. The client after receiving the variable **M2**, determines its own value **M2 = H(A, M1, K)**, and then compares the two values. If the values are equal, the identity of the server is confirmed by the client.

At the end of the authentication sequence, each party has an identical key (K), which can be used to encrypt further communication between client and server.

<img width="448" alt="srp-login" src="https://github.com/codebk1/safechat/assets/20027710/1cd01e9b-2526-461c-ae79-d74a9d4fdc9b">





