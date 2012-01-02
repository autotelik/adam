class String
  def upper_first_letter
      self[0].chr.capitalize + self[1, size]
  end

  def upper_first_letter!
      unless self[0] == (c = self[0,1].upcase[0])
        self[0] = c
        self
      end
      # Return nil if no change was made, like upcase! et al.
  end
end
