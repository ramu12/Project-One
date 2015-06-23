package org.mifosplatform.billing.planprice.exceptions;

import org.mifosplatform.infrastructure.core.exception.AbstractPlatformDomainRuleException;

@SuppressWarnings("serial")
public class ChargeCodeAndContractPeriodException extends AbstractPlatformDomainRuleException {

	public ChargeCodeAndContractPeriodException(final String chrgeCode) {
		super("error.msg.prepaid.chargecode.contract.should.be.same", "Contract period and bill frequency must be same for prepaid plans:"+chrgeCode, chrgeCode);
	}
	
	public ChargeCodeAndContractPeriodException() {
		super("error.msg.postpaid.billfrequency.less.than.contractperiod", "Bill Frequency must be less than Contract Period:");
	}
	
	public ChargeCodeAndContractPeriodException(final String chargeCode, final String contractPeriod) {
		super("error.msg.select.renewal.period.more.than", "Renewal Period should be more than:"+chargeCode, chargeCode);
	}

}