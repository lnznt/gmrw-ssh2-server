#!/usr/bin/env ruby

require 'openssl'

def sep(s, result=[])
  n, s = s.unpack("Na*")
  v, s = s.unpack("a#{n} a*")

  result << v
  
  s.empty? ? result : sep(s, result)
end

def dec(id, *nums)
  [id] + nums.map {|n| OpenSSL::BN.new(n, 2) }
end

ARGF.each do |line|
  form_id, s, mail = line.split(/\s+/)
  parsed = dec *(sep s.unpack("m")[0])

  case form_id
    when 'ssh-rsa'
      id, e, n = parsed
      puts <<-RSA
id = #{form_id}, mail = #{mail}
  id: #{id}
  e : #{e}
  n : #{n}

RSA

    when 'ssh-dss'
      id, p_, q, g, key = parsed
      puts <<-DSA
id = #{form_id}, mail = #{mail}
  id : #{id}
  p  : #{p_}
  q  : #{q}
  g  : #{g}
  key: #{key}

DSA

    else
      raise "unexpected format"
  end
end

# vim:set ts=2 sw=2 et ai:
