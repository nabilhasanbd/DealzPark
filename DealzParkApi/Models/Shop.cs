using System.ComponentModel.DataAnnotations;
using System.Text.Json.Serialization;

namespace DealzParkApi.Models
{
    public class Shop
    {
        public int Id { get; set; }

        [Required]
        [MaxLength(100)]
        public string ShopName { get; set; }

        [Required]
        [MaxLength(50)]
        public string NID { get; set; } // National ID

        [Required]
        [MaxLength(100)]
        public string TradeLicense { get; set; }

        [MaxLength(500)]
        public string ProductDetails { get; set; } // General description of products

        [MaxLength(100)]
        public string Location { get; set; } // e.g., City, Area

        [Required]
        [MaxLength(200)]
        public string Address { get; set; }

        [Required]
        [MaxLength(50)]
        public string ShopType { get; set; } // e.g., Retail, Online, Service

        // Navigation property for EF Core
        [JsonIgnore] // To prevent circular references in serialization
        public virtual ICollection<Offer> Offers { get; set; } = new List<Offer>();
    }
}