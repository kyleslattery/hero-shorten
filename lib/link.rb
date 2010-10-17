class Link
  include DataMapper::Resource
  
  property :id,  Serial
  property :url, Text
  
  def slug
    Link.encode(self.id)
  end
  
  def self.get_by_slug(slug)
    self.get(self.decode(slug))
  end
  
  CODESET = "0abcdefghijkmnpqrstuvwxyz23456789"
  
  def self.encode(n)
    base      = CODESET.size
    converted = ''
    
    while n > 0
      converted = CODESET[n%base,1].to_s + converted;
      n = (n/base).floor
    end
    
    converted
  end
  
  def self.decode(slug)
    base = CODESET.size
    sum  = 0
    slug.reverse!
    
    (0..(slug.length-1)).each do |n|
      sum += CODESET.index(slug[n,1]).to_i*(base**n)
    end
    
    sum
  end
end