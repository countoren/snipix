{ pkgs ? import <nixpkgs>{} 
}:
{
    tmssh-mac-oren = pkgs.writeShellScriptBin "tmssh-mac-oren" "${pkgs.sshpass}/bin/sshpass -f <(pass topmanage/ssh/macOren) ssh orenrozen@172.16.10.110";
    tmsshBambooLinuxAgentOld = pkgs.writeShellScriptBin "tmsshBambooLinuxAgentOld" "sshpass -f <(pass topmanage/ssh/bambooLinuxAgent) ssh orenrozen@172.16.31.38";

    tmsshBambooLinuxAgent = pkgs.writeShellScriptBin "tmsshBambooLinuxAgent" "ssh orenrozen@172.16.31.46";

    tmsshBambooLinuxAgentAsBambooUser = pkgs.writeShellScriptBin "tmsshBambooLinuxAgentAsBambooUser" "ssh -t orenrozen@172.16.31.46 'sudo su -l bambooagent'";

    tmsshCodeConsultingBamboo = 
      pkgs.writeShellScriptBin "tmsshCodeConsultingBamboo" "ssh orenrozen@172.16.31.57";

    tmsshCodeConsultingBambooAsBamboo = 
    pkgs.writeShellScriptBin "tmsshCodeConsultingBambooAsBamboo" "ssh -t orenrozen@172.16.31.57 'sudo su -l bamboo'";
}
