package org.mifosplatform.finance.billingorder.service;

import java.math.BigDecimal;
import java.util.List;

import org.mifosplatform.finance.billingorder.commands.BillingOrderCommand;
import org.mifosplatform.finance.billingorder.domain.BillingOrder;
import org.mifosplatform.finance.billingorder.domain.Invoice;
import org.mifosplatform.finance.clientbalance.domain.ClientBalance;
import org.mifosplatform.finance.clientbalance.domain.ClientBalanceRepository;
import org.mifosplatform.infrastructure.core.data.CommandProcessingResult;
import org.mifosplatform.organisation.office.domain.Office;
import org.mifosplatform.organisation.office.domain.OfficeAdditionalInfo;
import org.mifosplatform.organisation.office.domain.OfficeAdditionalInfoRepository;
import org.mifosplatform.organisation.office.domain.OfficeCommision;
import org.mifosplatform.organisation.office.domain.OfficeCommisionRepository;
import org.mifosplatform.organisation.partner.domain.PartnerBalanceRepository;
import org.mifosplatform.organisation.partner.domain.PartnerControlBalance;
import org.mifosplatform.organisation.partneragreement.data.AgreementData;
import org.mifosplatform.portfolio.client.domain.Client;
import org.mifosplatform.portfolio.client.domain.ClientRepository;
import org.mifosplatform.portfolio.order.domain.Order;
import org.mifosplatform.portfolio.order.domain.OrderPrice;
import org.mifosplatform.portfolio.order.domain.OrderRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

@Service
public class BillingOrderWritePlatformServiceImplementation implements BillingOrderWritePlatformService {


	private final OrderRepository orderRepository;
	private final ClientBalanceRepository clientBalanceRepository;
	private final ClientRepository clientRepository;
	private final PartnerBalanceRepository partnerBalanceRepository;
	private final OfficeAdditionalInfoRepository infoRepository;
	private final BillingOrderReadPlatformService billingOrderReadPlatformService;
	private final OfficeCommisionRepository officeCommisionRepository;
	
	@Autowired
	public BillingOrderWritePlatformServiceImplementation(final OrderRepository orderRepository,
			final ClientBalanceRepository clientBalanceRepository,
			final ClientRepository clientRepository,
			final PartnerBalanceRepository partnerBalanceRepository,
			final OfficeAdditionalInfoRepository infoRepository,
			final BillingOrderReadPlatformService billingOrderReadPlatformService,
			final OfficeCommisionRepository officeCommisionRepository){

		this.orderRepository = orderRepository;
		this.clientBalanceRepository = clientBalanceRepository;
		this.clientRepository = clientRepository;
		this.partnerBalanceRepository = partnerBalanceRepository;
		this.infoRepository = infoRepository;
		this.billingOrderReadPlatformService = billingOrderReadPlatformService;
		this.officeCommisionRepository = officeCommisionRepository;
	}


	@Override
	public CommandProcessingResult updateBillingOrder(List<BillingOrderCommand> commands) {
		Order clientOrder = null;
		
		for (BillingOrderCommand billingOrderCommand : commands) {
			
			clientOrder = this.orderRepository.findOne(billingOrderCommand.getClientOrderId());
				if (clientOrder != null) {
					
						clientOrder.setNextBillableDay(billingOrderCommand.getNextBillableDate());
						List<OrderPrice> orderPrices = clientOrder.getPrice();
						
						for (OrderPrice orderPriceData : orderPrices) {
							
						    if(billingOrderCommand.getOrderPriceId().equals(orderPriceData.getId())){
						    	
							orderPriceData.setInvoiceTillDate(billingOrderCommand.getInvoiceTillDate());
							orderPriceData.setNextBillableDay(billingOrderCommand.getNextBillableDate());
						
						}
					}
				}
				this.orderRepository.saveAndFlush(clientOrder);
		}
	
		return new CommandProcessingResult(Long.valueOf(clientOrder.getId()));
	}

	@Override
	public void updateClientBalance(Invoice invoice,Long clientId,boolean isWalletEnable) {
		
		BigDecimal balance=null;
		
		ClientBalance clientBalance = this.clientBalanceRepository.findByClientId(clientId);
		
		if(clientBalance == null){
			clientBalance =new ClientBalance(clientId,invoice.getInvoiceAmount(),isWalletEnable?'Y':'N');
		}else{
			if(isWalletEnable){
				balance=clientBalance.getWalletAmount().add(invoice.getInvoiceAmount());
				clientBalance.setWalletAmount(balance);
				
			}else{
				balance=clientBalance.getBalanceAmount().add(invoice.getInvoiceAmount());
				clientBalance.setBalanceAmount(balance);
			}
			

		}

		/*if (clientBalance != null) {

			clientBalance = updateClientBalance.calculateUpdateClientBalance("DEBIT",invoice.getInvoiceAmount(),clientBalance);
		} else if (clientBalance == null) {
			clientBalance = updateClientBalance.calculateCreateClientBalance("DEBIT",invoice.getInvoiceAmount(), clientBalance,invoice.getClientId());
		}*/

		this.clientBalanceRepository.saveAndFlush(clientBalance);
		
		final Client client = this.clientRepository.findOne(clientId);
		final OfficeAdditionalInfo officeAdditionalInfo = this.infoRepository.findoneByoffice(client.getOffice());
		if (officeAdditionalInfo != null) {
			if (officeAdditionalInfo.getIsCollective()) {
				
				this.updatePartnerBalance(client.getOffice(), invoice);
			}
		}

	}

	private void updatePartnerBalance(final Office office,final Invoice invoice) {

		final String accountType = "INVOICE";
		PartnerControlBalance partnerControlBalance = this.partnerBalanceRepository.findOneWithPartnerAccount(office.getId(), accountType);
		if (partnerControlBalance != null) {
			partnerControlBalance.update(invoice.getInvoiceAmount(), office.getId());

		} else {
			partnerControlBalance = PartnerControlBalance.create(invoice.getInvoiceAmount(), accountType,office.getId());
		}

		this.partnerBalanceRepository.save(partnerControlBalance);
	}

	@Override
	public void UpdateOfficeCommision(Invoice invoice, Long agreementId) {

		List<BillingOrder> charges = invoice.getCharges();

		for (BillingOrder charge : charges) {
      
			AgreementData data = this.billingOrderReadPlatformService.retrieveOfficeChargesCommission(charge.getId());
			if (data != null) {
				OfficeCommision commisionData = OfficeCommision.fromJson(data);
				this.officeCommisionRepository.save(commisionData);
			}else{}
           
		}
	}


	@Override
	public void updateClientVocherBalance(BigDecimal amount, Long clientId,
			boolean isWalletEnable) {
		// TODO Auto-generated method stub
		
	}



}
