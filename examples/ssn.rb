class Symbol
  def to_const
    Kernel.const_get self.to_s.split('_').map(&:capitalize).join
  end
end

module Rubi
  module Basic
    attr_reader :tables

    def table table
      @tables ||= Set.new
      @tables << table
    end
  end

  module Attribute
    include Basic

    attr_reader :parents, :children

    def neighbors; @parents + @children end

    def parent table
      @parents ||= Set.new
      @parents << table
    end

    def child table
      @children ||= Set.new
      @children << table
    end
  end

  module Fact
    include Basic

    attr_reader :fact

    def fact expression
      @fact = expression
    end
  end

  module Report
    def column attribute
      @nodes ||= Set.new
      @nodes << attribute
    end

    def metric metric
      @nodes ||= Set.new
      @nodes << metric
    end

    # def initialize
    #   @nodes.first
    # end
  end
end

#insert into ZZT5VPGB1WMMQ000
#selecta11.[CALL_CTR_ID] AS CALL_CTR_ID,
#CALL_CTR_IDa12.[YEAR_ID] AS YEAR_ID
#from[DAY_CTR_SLS]DAY_CTR_SLSa11,
#DAY_CTR_SLSa11[LU_DAY]LU_DAYa12
#wherea11.[DAY_DATE] = a12.[DAY_DATE]
#group bya11.[CALL_CTR_ID],
#CALL_CTR_IDa12.[YEAR_ID]
#havingsum((a11.[TOT_DOLLAR_SALES] - a11.[TOT_COST])) > 100000.0

#selecteda12.[YEAR_ID] AS YEAR_ID,
#YEAR_IDa11.[CALL_CTR_ID] AS CALL_CTR_ID,
#CALL_CTR_IDmax(a14.[CENTER_NAME]) AS CENTER_NAME,
#CENTER_NAMEa14.[REGION_ID] AS REGION_ID,
#REGION_IDmax(a15.[REGION_NAME]) AS REGION_NAME0,
#REGION_NAME0sum((a11.[TOT_DOLLAR_SALES] - a11.[TOT_COST])) AS WJXBFS1
#from[DAY_CTR_SLS]DAY_CTR_SLSa11,
#DAY_CTR_SLSa11[LU_DAY]LU_DAYa12,
#LU_DAYa12[ZZT5VPGB1WMMQ000]ZZT5VPGB1WMMQ000pa13,
#ZZT5VPGB1WMMQ000pa13[LU_CALL_CTR]LU_CALL_CTRa14,
#LU_CALL_CTRa14[LU_REGION]LU_REGIONa15
#wherea11a11.[DAY_DATE] = a12.[DAY_DATE] and
#anda11.[CALL_CTR_ID] = pa13.[CALL_CTR_ID] and
#anda12.[YEAR_ID] = pa13.[YEAR_ID] and
#anda11.[CALL_CTR_ID] = a14.[CALL_CTR_ID] and
#anda14.[REGION_ID] = a15.[REGION_ID]
#group bya11a12.[YEAR_ID],
#YEAR_IDa11.[CALL_CTR_ID],
#CALL_CTR_IDa14.[REGION_ID]
