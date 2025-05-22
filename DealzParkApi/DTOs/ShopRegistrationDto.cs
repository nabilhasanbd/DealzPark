using System.ComponentModel.DataAnnotations;

namespace DealzParkApi.DTOs
{
    public class ShopRegistrationDto
    {
        [Required]
        [MaxLength(100)]
        public string ShopName { get; set; }

        [Required]
        [MaxLength(50)]
        public string NID { get; set; }

        [Required]
        [MaxLength(100)]
        public string TradeLicense { get; set; }

        [MaxLength(500)]
        public string ProductDetails { get; set; }

        [MaxLength(100)]
        public string Location { get; set; }

        [Required]
        [MaxLength(200)]
        public string Address { get; set; }

        [Required]
        [MaxLength(50)]
        public string ShopType { get; set; }
    }
}