describe Travis::Yaml::Serializer::Yaml do
  subject(:config) { Travis::Yaml.parse('env: [{ secure: "foo" }, "bar"]') }

  example "serializes json" do
    expect(config.serialize(:yaml)).to be == "---\nenv:\n  matrix:\n  - !encrypted foo\n  - bar\nlanguage: ruby\nos:\n- linux\n"
  end

  example "complains about decrypted values missing" do
    expect { config.serialize(:yaml, secure: :decrypted) }.to raise_error(ArgumentError, 'secure option is set decrypted, but a secure value is not decrypted')
  end

  example "serializes decrypted values" do
    config.decrypt { |*| "x" }
    expect(config.serialize(:yaml, secure: :encrypted)).to be == "---\nenv:\n  matrix:\n  - !encrypted foo\n  - bar\nlanguage: ruby\nos:\n- linux\n"
    expect(config.serialize(:yaml, secure: :decrypted)).to be == "---\nenv:\n  matrix:\n  - !decrypted x\n  - bar\nlanguage: ruby\nos:\n- linux\n"
  end

  example "avoid tags" do
    config.decrypt { |*| "x" }
    expect(config.serialize(:yaml, secure: :encrypted, avoid_tags: true)).to be == "---\nenv:\n  matrix:\n  - secure: foo\n  - bar\nlanguage: ruby\nos:\n- linux\n"
    expect(config.serialize(:yaml, secure: :decrypted, avoid_tags: true)).to be == "---\nenv:\n  matrix:\n  - x\n  - bar\nlanguage: ruby\nos:\n- linux\n"
  end

  example "indentation" do
    expect(config.serialize(:yaml, indentation: 3)).to be == "---\nenv:\n   matrix:\n   - !encrypted foo\n   - bar\nlanguage: ruby\nos:\n- linux\n"
  end
end