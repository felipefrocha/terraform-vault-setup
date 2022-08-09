DO
$$
BEGIN
   IF NOT EXISTS (
      SELECT FROM pg_catalog.pg_roles  -- SELECT list can be empty for this
      WHERE  rolname = \"{{name}}\") THEN
      CREATE ROLE \"{{name}}\" LOGIN PASSWORD '{{password}}';
   ELSE 
      ALTER ROLE \"{{name}}\" WITH LOGIN ENCRYPTED PASSWORD '{{password}}';
   END IF;
END
$$;
