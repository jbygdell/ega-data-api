/*
 * Copyright 2017 ELIXIR EGA
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
package eu.elixir.ega.ebi.dataedge.config;

import org.springframework.core.io.ClassPathResource;
import org.springframework.util.FileCopyUtils;

import java.io.ByteArrayInputStream;
import java.io.ObjectInputStream;
import java.security.KeyFactory;
import java.security.PublicKey;
import java.security.Signature;
import java.security.spec.X509EncodedKeySpec;
import java.util.ArrayList;
import java.util.Base64;
import java.util.List;
import java.util.StringTokenizer;


public class VerifyMessage {

    private ArrayList<String> messages = new ArrayList<>();

    @SuppressWarnings("unchecked")
    //The constructor of VerifyMessage class retrieves the byte arrays from the File and prints the message only if the signature is verified.
    public VerifyMessage(String message) throws Exception {
        ByteArrayInputStream bais = new ByteArrayInputStream(Base64.getDecoder().decode(message));
        ObjectInputStream in = new ObjectInputStream(bais);
        List<byte[]> list = (List<byte[]>) in.readObject();
        in.close();

        String keyFile = "publicKey";
        if (verifySignature(list.get(0), list.get(1), keyFile)) {
            String permissions_timestamp = new String(list.get(0));

            StringTokenizer token = new StringTokenizer(permissions_timestamp, ",");
            String dataset = null;
            while (token.hasMoreElements()) {
                if (dataset != null) messages.add(dataset);
                dataset = token.nextToken();
            }

            // Check timestamp; if too old, wipe permissions (10 minutes) - has t be tested.... (different machines, different timezones...)
            long timestamp_delta = System.currentTimeMillis() - Long.parseLong(dataset);
            if (timestamp_delta > 600000)
                messages = new ArrayList<>();
        }

        //System.out.println(verifySignature(list.get(0), list.get(1), keyFile) ? "VERIFIED MESSAGE" + "\n----------------\n" + new String(list.get(0)) : "Could not verify the signature.");
    }

    //Method for signature verification that initializes with the Public Key, updates the data to be verified and then verifies them using the signature
    private boolean verifySignature(byte[] data, byte[] signature, String keyFile) throws Exception {
        Signature sig = Signature.getInstance("SHA1withRSA");
        sig.initVerify(getPublic(keyFile));
        sig.update(data);

        return sig.verify(signature);
    }

    //Method to retrieve the Public Key from a file
    private PublicKey getPublic(String filename) throws Exception {
        ClassPathResource cpr = new ClassPathResource(filename);
        byte[] keyBytes = FileCopyUtils.copyToByteArray(cpr.getInputStream());
        X509EncodedKeySpec spec = new X509EncodedKeySpec(keyBytes);
        KeyFactory kf = KeyFactory.getInstance("RSA");
        return kf.generatePublic(spec);
    }

    public ArrayList<String> getPermissions() {
        return this.messages;
    }

}
