package org.mifosplatform.portfolio.order.domain;

import java.math.BigDecimal;
import java.util.Date;

import javax.persistence.Column;
import javax.persistence.Entity;
import javax.persistence.JoinColumn;
import javax.persistence.ManyToOne;
import javax.persistence.OneToOne;
import javax.persistence.Table;

import org.joda.time.LocalDate;
import org.springframework.data.jpa.domain.AbstractPersistable;

@Entity
@Table(name = "b_order_discount")
public class OrderDiscount extends AbstractPersistable<Long> {

/*	@Id
	@GeneratedValue
	@Column(name = "id")
	private Long id;
*/
	
	@Column(name = "discount_id")
	private Long discountId;

	@Column(name = "discount_type")
	private String discountType;

	@Column(name = "discount_rate")
	private BigDecimal discountRate;

	
	@Column(name = "discount_startdate")
	private Date discountStartdate;

	@Column(name = "discount_enddate")
	private Date discountEndDate;
	
	

	@ManyToOne
	@JoinColumn(name="order_id")
	private Order order;
	
	@OneToOne
	@JoinColumn(name="orderprice_id")
	private OrderPrice orderpriceid;
	
	public  OrderDiscount() {
		// TODO Auto-generated constructor stub
	}
	
	public OrderDiscount(Order order, OrderPrice orderPrice, Long discountId,Date startDate, LocalDate endDate,
			String discountType,BigDecimal discountRate) {
		
              this.order=order;
              this.orderpriceid=orderPrice;
              this.discountId=discountId;
              this.discountStartdate=startDate;
              if(endDate!=null){
              this.discountEndDate=endDate.toDate();
              }
              this.discountType=discountType;
              this.discountRate=discountRate;
	}

	public Long getDiscountId() {
		return discountId;
	}

	public String getDiscountType() {
		return discountType;
	}

	public BigDecimal getDiscountRate() {
		return discountRate;
	}

	public Date getDiscountStartdate() {
		return discountStartdate;
	}

	public Date getDiscountEndDate() {
		return discountEndDate;
	}

	public Order getOrder() {
		return order;
	}

	public OrderPrice getOrderpriceid() {
		return orderpriceid;
	}

	public void updateDates(BigDecimal discountRate, String discountType, LocalDate enddate) {
         
		  this.discountStartdate=new Date();
		  if(enddate != null){
		  this.discountEndDate=enddate.toDate();
		  }
		  this.discountRate=discountRate;
		  this.discountType=discountType;
		
	}

	public void update(Order order) {
		this.order=order;
		
	}

	public void updateOrderPrice(OrderPrice orderPrice) {
		this.orderpriceid=orderPrice;
		
	}


}
