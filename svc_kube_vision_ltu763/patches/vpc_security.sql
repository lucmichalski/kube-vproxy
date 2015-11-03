-- Launch LTU model

INSERT INTO client_ip_whitelist VALUES (NOW(), NOW(), 1, '0.0.0.0/0', 1, 'Loopback network (insecure).');
