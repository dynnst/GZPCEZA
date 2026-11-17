using System;

namespace gzpegm.Models.ViewModels
{
    public class FormPrintViewModel
    {
        public string PassengerName { get; set; }
        public string FirstName { get; set; }
        public string LastName { get; set; }
        public string FatherName { get; set; }
        public string MotherName { get; set; }
        public string Nationality { get; set; }
        public string PassportNo { get; set; }
        public string Birthdate { get; set; }
        public string CommunicationLanguage { get; set; }

        public string EntryDate { get; set; }
        public string ApplicationDate { get; set; }
        public string ShouldExitDate { get; set; }
        public string CanEnterDate { get; set; }
        public string VisaDistanceDays { get; set; }
        public string ViolationPeriod { get; set; }
        public string FineAmount { get; set; }
        public string FinePriceTotal { get; set; }
        public string DefterPrice { get; set; }
        public string TahditCode { get; set; }
        public string EntryBanDays { get; set; }

        public string PoliceOfficer { get; set; }
        public string ApprovalUser { get; set; }
        public string BorderGate { get; set; }
        public string Province { get; set; }
        public string Today { get; set; }
        public string CurrentTime { get; set; }

        public bool IsPaid { get; set; }
        public bool IsAdult { get; set; }
        public bool IsOver90 { get; set; }
        public bool HasCKodlu { get; set; }
        public bool HasNKodlu { get; set; }

        public string LanguageCode { get; set; } // "GB", "RU", "DE", "FR", "IR", "IRK", "Cin", "Yunan"
        public string QrText { get; set; }
    }
}
