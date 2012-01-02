FpML 5.1 - Readme file
===========================================

There are two sets of documentation for each view published in FpML:
* confirmation - contains the confirmation view of FpML
* reporting - contains the reporting view of FpML


For each of these views, there are schema files and example subddirectories.


Confirmation Schemas:

The schema files are labelled fpml-XXX-5-1.xsd, as follows:
	* example-extension-5-1.xsd - File containing an example of an extension from the 5.0 confirmation view schemas.
	* fpml-asset-5-1.xsd - Underlyer definitions plus some types used by them (e.g. ones relating to commissions or dividend payouts).
	* fpml-bond-option-5-1.xsd - Bond and Convertible Bond Options Product Definitions.
	* fpml-business-events-5-1.xsd - Content of the Business events components
	* fpml-cd-5-1.xsd - Credit derivative product definitions.
	* fpml-com-5-1.xsd - Commodity product definitions.
   	* fpml-confirmation-processes-5-1.xsd - Confirmation process messages.
  	* fpml-correlation-swap-5-1.xsd - Correlation Swap Product Definitions.
	* fpml-dividend-swaps-5-1.xsd - Dividend Swap Product Definitions.
	* fpml-doc-5-1.xsd - Trade and contract definitions and definitions relating to validation.
	* fpml-enum-5-1.xsd - Shared enumeration definitions. These definitions list the values that enumerated types may take.
  	* fpml-eqd-5-1.xsd - Equity Option and Equity Forward Product Definitions.
  	* fpml-eq-shared-5-1.xsd - Definitions shared by types with Equity Underlyers.
	* fpml-fx-5-1.xsd - Foreign Exchange Product Definitions.
	* fpml-ird-5-1.xsd - Interest rate derivative product definitions.
	* fpml-main-5-1.xsd - Root definitions.
   	* fpml-msg-5-1.xsd - High level definitions related to messaging.
	* fpml-option-shared-5-1.xsd - Shared option definitions used for defining the common features of options.
	* fpml-return-swaps-5-1.xsd - Return Swaps Product Definitions.
    	* fpml-shared-5-1.xsd - Shared definitions used widely throughout the specification. These include items such as base types, shared financial structures, etc.
    	* fpml-variance-swap-5-1.xsd - Variance Swap Product Definitions.
   	* xmldsig-core-schema.xsd - W3C Digital Signature Schema
 
  

Reporting Schemas:

The schema files are labelled fpml-XXX-5-1.xsd, as follows:
* example-extension-5-1.xsd - File containing an example of an extension from the 5.0 confirmation view schemas.
	* fpml-asset-5-1.xsd - Underlyer definitions plus some types used by them (e.g. ones relating to commissions or dividend payouts).
	* fpml-bond-option-5-1.xsd - Bond and Convertible Bond Options Product Definitions.
	* fpml-business-events-5-1.xsd - Content of the Business events components
	* fpml-cd-5-1.xsd - Credit derivative product definitions.
	* fpml-collateral-processes-5-1.xsd - Collateral process messages.
	* fpml-com-5-1.xsd - Commodity product definitions.
    	* fpml-correlation-swap-5-1.xsd - Correlation Swap Product Definitions.
	* fpml-credit-event-notification-5-1.xsd - Credit event notification components.
	* fpml-dividend-swaps-5-1.xsd - Dividend Swap Product Definitions.
	* fpml-doc-5-1.xsd - Trade and contract definitions and definitions relating to validation.
	* fpml-enum-5-1.xsd - Shared enumeration definitions. These definitions list the values that enumerated types may take.
  	* fpml-eqd-5-1.xsd - Equity Option and Equity Forward Product Definitions.
  	* fpml-eq-shared-5-1.xsd - Definitions shared by types with Equity Underlyers.
	* fpml-fx-5-1.xsd - Foreign Exchange Product Definitions.	
	* fpml-generic-5-1.xsd - Generic definitions for reporting.
 	* fpml-ird-5-1.xsd - Interest rate derivative product definitions.
	* fpml-main-5-1.xsd - Root definitions.
	* fpml-mktenv-5-1.xsd – Definitions of market environment data structures such as yield curves, volatility matrices, and the like.
 	* fpml-msg-5-1.xsd - Definitions related to messaging and workflow.
	* fpml-option-shared-5-1.xsd - Shared option definitions used for defining the common features of options.
	* fpml-reconciliation-5-1.xsd - Cash flow matching and Portfolio Reconciliation messaging components    
	* fpml-reporting-5-1.xsd – Messages used for requesting and providing valuation reporting results.
	* fpml-return-swaps-5-1.xsd - Return Swaps Product Definitions.
	* fpml-riskdef-5-1.xsd – Definitions of valuation and sensitivity results. They include detailed definitions of sensitivity calculations and are intended to be used by sophisticated users.
 	* fpml-shared-5-1.xsd - Shared definitions used widely throughout the specification. These include items such as base types, shared financial structures, etc.
	* fpml-valuation-5-1.xsd – Valuation result sets and related definitions.
	* fpml-variance-swap-5-1.xsd - Variance Swap Product Definitions.
	* xmldsig-core-schema.xsd - W3C Digital Signature Schema


Plus, each view directory contains subdirectories for each group of FpML examples, namely:

confirmation/business-processes/
 * allocation
 * clearing
 * confirmation
 * consent
 * execution-advice
 * execution-notification
 * option-expiration-notification
 * trade-change-advice

confirmation/products/
 * bond-options
 * commodity-derivatives
 * credit-derivatives
 * correlation-swaps
 * dividend-swaps
 * equit-forwards
 * equity-options
 * equity-swaps
 * fx-derivatives
 * inflation-swaps
 * interest-rate-derivatives
 * total-return-swaps
 * variance-swaps

confirmation/validation/
 * invalid-testcases

reporting/
 * cash flow matching
 * collateral
 * credit-event-notice
 * entity-reporting
 * party-reporting
 * portfolio-reconciliation
 * position-and-activity-reporting
 * reset-reporting
 * valuation



Each subdirectory contains a number of example files.  These files are named as follows:
YY_exNN_long_description.xml, 
where
YY is the subset identifier and
NN is an integer number.

The examples have a schemaLocation attribute that references their parent 
directory.  In other words, the FpML schema must be present in the parent 
directory of the example file for the example file to validate using the 
schemaLocation attribute.

The schemaLocation attribute previously referenced the examples' own directory, 
and extra copies of the schema files were placed in each example directory.
This simplified validation of the examples and helped certain tools to work
properly, but caused some users confusion.

The examples have been validated using Xerces J v 2.4.1.