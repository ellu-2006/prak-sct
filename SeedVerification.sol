// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract SeedVerification {

    // Owner (admin utama)
    address public owner;

    constructor() {
        owner = msg.sender;
    }

    // Modifier untuk membatasi akses
    modifier onlyOwner() {
        require(msg.sender == owner, "Hanya owner yang bisa akses");
        _;
    }

    modifier onlyProducer() {
        require(producers[msg.sender] == true, "Bukan produsen");
        _;
    }

    modifier onlyVerifier() {
        require(verifiers[msg.sender] == true, "Bukan verifikator");
        _;
    }

    // Struktur data benih
    struct Seed {
        uint id;
        string name;
        string quality;
        string description;
        uint productionDate;
        bool isVerified;
        address producer;
    }

    // Mapping data
    mapping(uint => Seed) public seeds;
    mapping(address => bool) public producers;
    mapping(address => bool) public verifiers;

    uint public seedCount = 0;

    // Event untuk transparansi (log blockchain)
    event SeedRegistered(uint id, string name, address producer);
    event SeedVerified(uint id, bool status, address verifier);

    // =============================
    // ROLE MANAGEMENT
    // =============================

    function addProducer(address _producer) public onlyOwner {
        producers[_producer] = true;
    }

    function addVerifier(address _verifier) public onlyOwner {
        verifiers[_verifier] = true;
    }

    // =============================
    // REGISTRASI BENIH
    // =============================

    function registerSeed(
        string memory _name,
        string memory _quality,
        string memory _description,
        uint _productionDate
    ) public onlyProducer {

        seedCount++;

        seeds[seedCount] = Seed({
            id: seedCount,
            name: _name,
            quality: _quality,
            description: _description,
            productionDate: _productionDate,
            isVerified: false,
            producer: msg.sender
        });

        emit SeedRegistered(seedCount, _name, msg.sender);
    }

    // =============================
    // VERIFIKASI BENIH
    // =============================

    function verifySeed(uint _id, bool _status) public onlyVerifier {
        require(_id > 0 && _id <= seedCount, "ID tidak valid");

        seeds[_id].isVerified = _status;

        emit SeedVerified(_id, _status, msg.sender);
    }

    // =============================
    // CEK DATA BENIH
    // =============================

    function getSeed(uint _id) public view returns (
        uint,
        string memory,
        string memory,
        string memory,
        uint,
        bool,
        address
    ) {
        require(_id > 0 && _id <= seedCount, "ID tidak valid");

        Seed memory s = seeds[_id];

        return (
            s.id,
            s.name,
            s.quality,
            s.description,
            s.productionDate,
            s.isVerified,
            s.producer
        );
    }

    // =============================
    // CEK STATUS VERIFIKASI
    // =============================

    function isSeedVerified(uint _id) public view returns (bool) {
        require(_id > 0 && _id <= seedCount, "ID tidak valid");
        return seeds[_id].isVerified;
    }

    // =============================
    // TOTAL DATA
    // =============================

    function getTotalSeeds() public view returns (uint) {
        return seedCount;
    }
}